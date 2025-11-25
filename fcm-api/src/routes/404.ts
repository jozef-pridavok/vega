import { HTTP } from "#enums/index.js";
import type { Express } from "express";

export default (app: Express) => {
    app.all("*", (_req, res) => {
        return res.sendStatus(HTTP.NOT_FOUND);
    });
};
