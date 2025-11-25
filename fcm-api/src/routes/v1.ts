import type { Express } from "express";

import Message from "./v1/message.js";

export default (app: Express) => {
    app.use("/v1/message", Message);
};
