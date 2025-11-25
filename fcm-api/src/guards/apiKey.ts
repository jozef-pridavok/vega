import { HTTP } from "#enums/index.js";
import { API_KEY } from "#src/env.js";
import type { NextFunction, Request, Response } from "express";

export const apiKey = (req: Request, res: Response, next: NextFunction) => {
    const nonSecurePaths = ["/ping"];
    if (nonSecurePaths.includes(req.path)) {
        return next();
    }
    if (API_KEY !== req.headers["x-api-key"]) {
        return res.sendStatus(HTTP.UNAUTHORIZED);
    }
    return next();
};
