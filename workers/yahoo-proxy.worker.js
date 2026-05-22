// Deploy to Cloudflare Workers
// wrangler deploy yahoo-proxy.worker.js
// Route: e.g. https://yahoo-proxy.kylinyu.win/price?symbol=00631L.TW

export default {
  async fetch(request) {
    const origin = request.headers.get('Origin') || '';
    const allowedOrigins = ['https://kylinyu.win', 'https://yahoo-proxy.yahooproxy.workers.dev'];
    const corsOrigin = allowedOrigins.includes(origin) ? origin : 'https://kylinyu.win';

    const url = new URL(request.url);
    const symbol = url.searchParams.get('symbol') || '00631L.TW';

    const HEADERS = {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      'Accept': 'application/json',
    };

    // Step 1: get crumb + cookie
    const crumbRes = await fetch('https://query2.finance.yahoo.com/v1/test/getcrumb', {
      headers: HEADERS,
    });
    const crumb = (await crumbRes.text()).trim();
    const cookie = crumbRes.headers.get('set-cookie') ?? '';

    // Step 2: fetch chart data
    const chartUrl =
      `https://query2.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}` +
      `?interval=1d&range=1d&crumb=${encodeURIComponent(crumb)}`;

    const chartRes = await fetch(chartUrl, {
      headers: { ...HEADERS, Cookie: cookie },
    });
    const data = await chartRes.json();

    const meta = data?.chart?.result?.[0]?.meta;
    const price = meta?.regularMarketPrice ?? null;
    const ts    = meta?.regularMarketTime  ?? null;

    return new Response(
      JSON.stringify({ price, ts, symbol }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': corsOrigin,
          'Cache-Control': 'public, max-age=60',
        },
      }
    );
  },
};
