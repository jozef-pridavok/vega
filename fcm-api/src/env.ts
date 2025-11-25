import * as dotenv from "dotenv";
import { z } from "zod";
import Logger from "./services/logger.js";

dotenv.config();

// TODO: Doriesit parsovanie cisiel a booleanov
const schema = z.object({
    NODE_ENV: z.enum(["development", "production"]),
    PORT: z.string().optional(),
    API_KEY: z.string(),
    LOG_LEVELS: z.string(),
    GOOGLE_APPLICATION_CREDENTIALS: z.string(),
});

const logger = new Logger({ namespace: "env", levels: { error: true } });
const parsed = schema.safeParse(process.env);
if (!parsed.success) {
    logger.error(
        "❌ Invalid environment variables:",
        JSON.stringify(parsed.error.format(), null, 4)
    );
    process.exit(1);
}

export const { NODE_ENV, PORT, API_KEY, LOG_LEVELS, GOOGLE_APPLICATION_CREDENTIALS } = parsed.data;
export default parsed.data;
