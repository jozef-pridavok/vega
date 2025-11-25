import Logger from "#services/logger.js";
import c from "ansi-colors";
import type { NextFunction, Request } from "express";
import type { IncomingMessage, ServerResponse } from "http";
import onFinished from "on-finished";
import onHeaders from "on-headers";

interface AccessRequest extends Request {
    _startAt?: [number, number];
}
interface AccessResponse extends ServerResponse<IncomingMessage> {
    _startAt?: [number, number];
}

const logger = new Logger({ namespace: "access" });

function recordStartTime(this: AccessRequest | AccessResponse) {
    this._startAt = process.hrtime();
}

const getPerfMS = (start: [number, number], end: [number, number]) => {
    return (end[0] - start[0]) * 1e3 + (end[1] - start[1]) * 1e-6;
};

export const logAccess = (req: AccessRequest, res: AccessResponse, next: NextFunction) => {
    req._startAt = undefined;
    res._startAt = undefined;
    recordStartTime.call(req);

    onHeaders(res, recordStartTime);
    onFinished(res, (_err, res) => {
        if (!req._startAt || !res._startAt) {
            return 0;
        }
        const contentLength = res.getHeader("Content-Length") ?? "N/A";
        const responseTime = getPerfMS(req._startAt, res._startAt).toFixed(3);

        const statusCode = res.statusCode;
        let color: c.StyleFunction;
        if (statusCode > 499) {
            color = c.magenta;
        } else if (statusCode > 399) {
            color = c.red;
        } else if (statusCode > 299) {
            color = c.yellow;
        } else {
            color = c.green;
        }

        logger.trace(
            `${req.method} ${req.originalUrl} ${color(
                statusCode.toString()
            )} ${responseTime} ms - ${contentLength}`
        );
    });
    return next();
};
