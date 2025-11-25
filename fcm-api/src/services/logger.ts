import env from "#src/env.js";
import c from "ansi-colors";

type Level = "trace" | "debug" | "info" | "warn" | "error" | "fatal";
type Levels = Partial<Record<Level, boolean>>;

const colors: Record<Level, c.StyleFunction> = {
    trace: c.bold,
    debug: c.cyan.bold,
    info: c.green.bold,
    warn: c.yellowBright.bold,
    error: c.red.bold,
    fatal: c.magenta.bold.dim,
};

export class Logger {
    #namespace = "default";
    #levels: Map<Level, boolean> = new Map();

    constructor({ namespace, levels }: { namespace?: string; levels?: Levels } = {}) {
        if (namespace) {
            this.setNamespace(namespace);
        }

        if (levels) {
            this.setLevels(levels);
        } else if (env.LOG_LEVELS) {
            env.LOG_LEVELS.split(",").forEach((level) => {
                this.setLevel(level as Level, true);
            });
        }
    }

    setLevel(level: Level | "all", enable = true) {
        if (level === "all") {
            this.#levels.set("trace", enable);
            this.#levels.set("debug", enable);
            this.#levels.set("info", enable);
            this.#levels.set("warn", enable);
            this.#levels.set("error", enable);
            this.#levels.set("fatal", enable);
            return 0;
        }
        this.#levels.set(level, enable);
    }
    getLevel(level: Level) {
        return this.#levels.get(level);
    }
    setLevels(levels: Levels) {
        Object.entries(levels).forEach(([level, enable]) => {
            this.setLevel(level as Level, enable);
        });
    }
    getLevels() {
        console.log(this.#levels);
        return this.#levels;
    }
    setNamespace(namespace?: string) {
        if (namespace) this.#namespace = namespace;
    }
    getNamespace() {
        return this.#namespace;
    }
    #colorMessage(template: string[]) {
        const ct = template.slice(0);
        ct[0] = c.grey(ct[0]);
        const level = ct[1];
        ct[1] = colors[level.toLowerCase() as Level](level.toUpperCase().padEnd(5, " "));
        ct[3] = c.grey(ct[3]);
        return ct.join(" ") + "\n";
    }
    #serialize(data: unknown[]) {
        const serialized: string[] = [];

        data.forEach((item) => {
            if (typeof item === "string") {
                return serialized.push(item);
            }
            if (item === undefined) {
                return serialized.push("undefined");
            }
            if (item === null) {
                return serialized.push("null");
            }
            if (item instanceof Error) {
                return this.error(item.stack);
            }
            if (typeof item === "object") {
                return serialized.push(JSON.stringify(item));
            }
            if (typeof item === "number") {
                return serialized.push(item.toString());
            }
        });
        return serialized;
    }
    #log(level: Level, message: unknown[]) {
        const now = new Date();
        const datetime = now.toISOString().replace("T", " ");

        const serialized = this.#serialize(message);

        if (!serialized.length) {
            return;
        }

        const template = [datetime, level, this.#namespace, "-", ...serialized];

        process.stdout.write(this.#colorMessage(template));

        return template.join(" ");
    }
    trace(...message: unknown[]) {
        if (this.#levels.get("trace")) return this.#log("trace", message);
    }
    t(...message: unknown[]) {
        return this.trace(message);
    }
    debug(...message: unknown[]) {
        if (this.#levels.get("debug")) return this.#log("debug", message);
    }
    d(...message: unknown[]) {
        return this.debug(message);
    }
    info(...message: unknown[]) {
        if (this.#levels.get("info")) return this.#log("info", message);
    }
    i(...message: unknown[]) {
        return this.info(message);
    }
    warn(...message: unknown[]) {
        if (this.#levels.get("warn")) return this.#log("warn", message);
    }
    w(...message: unknown[]) {
        return this.warn(message);
    }
    error(...message: unknown[]) {
        if (this.#levels.get("error")) return this.#log("error", message);
    }
    e(...message: unknown[]) {
        return this.error(message);
    }
    fatal(...message: unknown[]) {
        if (this.#levels.get("fatal")) return this.#log("fatal", message);
    }
    f(...message: unknown[]) {
        return this.fatal(message);
    }
}
export default Logger;
