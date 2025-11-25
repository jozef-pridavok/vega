import { HTTP } from "#enums/index.js";
import { AppError } from "#models/AppError.js";
import Logger from "#services/logger.js";
import type { NextFunction, Request, Response } from "express";

export function errorHandler(
    err: Error | AppError,
    _req: Request,
    res: Response,
    _next: NextFunction
) {
    const logger = new Logger();

    if (err instanceof AppError) {
        err.logger.error(err);
        return res.status(err.code).send(err.code !== 500 ? err.message : undefined);
    } else {
        logger.error(err);
    }

    return res.sendStatus(HTTP.INTERNAL_SERVER_ERROR);
}
