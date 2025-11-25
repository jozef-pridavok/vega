import { HTTP } from "#enums/index.js";
import { AppError } from "#models/index.js";
import Logger from "#services/logger.js";
import { NextFunction, Request, Response, Router } from "express";
import {
    BaseMessage,
    MulticastMessage,
    TokenMessage,
    getMessaging,
} from "firebase-admin/messaging";

const router = Router();
const logger = new Logger({ namespace: "messaging" });
const maxMulticastTokens = 500;

function chunkArray(array: string[], chunkSize: number) {
    const result = [];
    for (let i = 0; i < array.length; i += chunkSize) {
        const chunk = array.slice(i, i + chunkSize);
        result.push(chunk);
    }
    return result;
}

type pushRequestBody = {
    pushTitle: string;
    pushBody: string;
    tokens: string[];
    payload?: Record<string, any>;
};

router.post(
    "/",
    async (
        req: Request<Record<string, any>, Record<string, any>, pushRequestBody>,
        res: Response,
        next: NextFunction
    ) => {
        try {
            if (
                !Array.isArray(req.body.tokens) ||
                !req.body.tokens.length ||
                !req.body.pushTitle ||
                !req.body.pushBody
            ) {
                return res.sendStatus(HTTP.BAD_REQUEST);
            }
            const { payload, pushBody, pushTitle, tokens } = req.body;
            const defaultMessaging = getMessaging();

            const message: BaseMessage = {
                data: payload || {},
                notification: {
                    title: pushTitle,
                    body: pushBody,
                },
            };
            const failureTokens: string[] = [];
            try {
                if (tokens.length > 1) {
                    const chunksOfTokens = chunkArray(tokens, maxMulticastTokens);
                    for (const tokensChunk of chunksOfTokens) {
                        (<MulticastMessage>message).tokens = tokensChunk;
                        const response = await defaultMessaging.sendEachForMulticast(
                            message as MulticastMessage
                        );
                        response.responses.forEach((messageResponse, index: number) => {
                            if (messageResponse.success) {
                                logger.i("Successfully sent message:", messageResponse.messageId);
                            } else {
                                logger.warn(
                                    "Message failed to be sent to token:",
                                    tokensChunk[index]
                                );
                                failureTokens.push(tokensChunk[index]);
                            }
                        });
                    }
                } else {
                    (<TokenMessage>message).token = tokens[0];
                    const response = await defaultMessaging.send(message as TokenMessage);
                    logger.i("Successfully sent message:", response);
                }
            } catch (error) {
                logger.e("Error sending message:", error);
                if (!failureTokens.length) {
                    failureTokens.push(...tokens);
                }
            }
            return res.status(HTTP.OK).json({ failureTokens });
        } catch (error) {
            next(new AppError().from(error as Error).setLogger(logger));
        }
    }
);

export default router;
