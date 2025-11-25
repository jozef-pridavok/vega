import { HTTP } from "#enums/index.js";
import Logger from "#services/logger.js";

export class AppError extends Error {
    code: number;
    logger: Logger;

    constructor(message?: string | number, code?: number, logger?: Logger) {
        super();
        this.message = message?.toString() ?? "";
        this.code = code ?? HTTP.INTERNAL_SERVER_ERROR;
        this.logger = logger ?? new Logger();
    }

    from(error: Error) {
        this.message = error.message;
        this.stack = error.stack;
        return this;
    }

    setLogger(logger: Logger) {
        this.logger = logger;
        return this;
    }
}
