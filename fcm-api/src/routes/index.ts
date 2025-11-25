import { HTTP } from "#enums/index.js";
import { AppError } from "#models/index.js";
import Logger from "#services/logger.js";
import type { Express } from "express";
import { NextFunction, Request, Response, Router } from "express";

const router = Router();
const logger = new Logger({ namespace: "index" });

router.get("/ping", async (req: Request, res: Response, next: NextFunction) => {
    try {
        return res.status(HTTP.OK).json({
            version: process.env.TAG_NAME,
        });
    } catch (error) {
        next(new AppError().from(error as Error).setLogger(logger));
    }
});

export default (app: Express) => {
    app.use("/", router);
};
