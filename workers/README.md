# Cloudflare Workers

## yahoo-proxy

Yahoo Finance API 不允許 cross-origin 請求，此 Worker 作為伺服器端 proxy，
繞過 CORS 限制並處理 Yahoo Finance 的 crumb 認證流程。

### Endpoint

```
GET https://yahoo-proxy.yahooproxy.workers.dev/price?symbol=00631L.TW
```

Response:
```json
{ "price": 31.82, "ts": 1779419273, "symbol": "00631L.TW" }
```

### 部署

需先安裝並登入 wrangler：

```bash
npm install -g wrangler
wrangler login
```

部署（或從 repo 根目錄用 make）：

```bash
make deploy-worker
# 等同於：
cd workers && wrangler deploy yahoo-proxy.worker.js --name yahoo-proxy
```

### 允許的 Origin

`workers/yahoo-proxy.worker.js` 中的 `allowedOrigins` 陣列控制 CORS：

```js
const allowedOrigins = ['https://kylinyu.win', 'https://yahoo-proxy.yahooproxy.workers.dev'];
```

新增來源時修改此陣列並重新 `make deploy-worker`。

### 用途

目前用於 `baseline.html`（00631L 基準線計算器，對外路徑 `/baseline/`）的即時報價功能。
