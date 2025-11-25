import fs from "fs";
import packageJson from "./package.json" assert { type: "json" };

fs.writeFileSync(
    "dist/package.json",
    JSON.stringify(
        {
            ...packageJson,
            devDependencies: undefined,
            scripts: {
                start: "NODE_ENV=production node index.js",
            },
        },
        null,
        2
    )
);
