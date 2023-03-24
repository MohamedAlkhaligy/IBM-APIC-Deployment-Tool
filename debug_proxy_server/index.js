const express = require('express');
const cors = require('cors');
const {
	createProxyMiddleware, responseInterceptor
} = require('http-proxy-middleware');
const YAML = require('js-yaml');
let log4js = require('log4js');

log4js.configure({
	appenders: {
		console: {
			type: 'console'
		},
		globalPoliciesLogs: {
			type: 'file',
			filename: 'logs/global_policies.log'
		}
	},
	categories: {
		global_policies: {
			appenders: ['globalPoliciesLogs'],
			level: 'debug'
		},
		default: {
			appenders: ['console'],
			level: 'trace'
		}
	}
});

const configurations = require("./configurations.json");

// Create Express Server
const app = express();
const defaultTargetURL = configurations.proxy['default-target-url'];
const xProxyTargetURLHeader = "x-proxy-target-url";
const xProxyOperationIDHeader = "x-proxy-operation-id";

app.use(cors());

const customRouter = function(req) {
	if (req.headers[xProxyTargetURLHeader]) {
		// console.log(`New Target URL: ${req.headers[targetURLHeader]}`);
		return req.headers[xProxyTargetURLHeader];
	} else {
		return defaultTargetURL;
	}
};

// Req -> [Proxy Server] -> proxyReq -> [Target Server]
// Res -> [Proxy Server] <- proxyRes <- [Target Server]
app.use(createProxyMiddleware({
	target: defaultTargetURL,
	changeOrigin: true,
	selfHandleResponse: true,
	secure: false,
	logLevel: 'debug',
	router: customRouter,
	onProxyReq: function(proxyReq) {
		let headers = new Map(Object.entries(configurations.headers));
		headers.forEach((value, key) => proxyReq.setHeader(key, value));

	},
	onProxyRes: responseInterceptor(async(buffer, proxyRes, req, res) => {
		const body = buffer.toString();
		console.log(body);
		res.setHeader("access-control-allow-origin", "*");
		const logger = log4js.getLogger('global_policies');
		if (req.headers[xProxyOperationIDHeader] === "getGlobalPolicyYAML" && req.headers.accept === 'application/yaml' && res.statusCode === 200) {
			const body = buffer.toString();
			const yamlBody = YAML.load(body, {});
			if (yamlBody.global_policy) {
				logger.debug(YAML.dump(yamlBody.global_policy));
				return YAML.dump(yamlBody.global_policy, {
					forceQuotes: false
				});
			}
		}
		return buffer.toString();
	})
}));

// Start the Proxy
app.listen(configurations.proxy.port, configurations.proxy.host, () => {
	console.log(`Starting Proxy at ${configurations.proxy.host}:${configurations.proxy.port}`);
});