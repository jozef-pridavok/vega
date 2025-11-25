import cors from "cors";
import express from "express";
import { applicationDefault, initializeApp } from "firebase-admin/app";
import helmet from "helmet";
import env from "./env.js";
import { apiKey } from "./guards/index.js";
import { errorHandler, logAccess } from "./middlewares/index.js";
import error404 from "./routes/404.js";
import indexRouter from "./routes/index.js";
import v1 from "./routes/v1.js";

const app = express();

app.use(helmet());
app.use(express.json({ limit: "2mb" }));
app.use(express.urlencoded({ limit: "2mb", extended: false }));
app.use(express.static("public"));

app.use(logAccess);
app.use(apiKey);

indexRouter(app);
v1(app);
error404(app);

app.use(errorHandler);

const args = process.argv.slice(2);
const port = args[0] ? parseInt(args[0]) : env.PORT ? parseInt(env.PORT) : 8000;
app.listen(port, async () => {
    console.log("\x1b[32m%s\x1b[0m", `[server] 🚀 http://localhost:${port}`);
    // Initialize Firebase SDK
    initializeApp({
        credential: applicationDefault(),
    });
});
