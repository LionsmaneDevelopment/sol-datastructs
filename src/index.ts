import dotenv from 'dotenv';

if (process.env.NODE_ENV == 'development') {
    dotenv.config();
}

function main() {
    const NAME = process.env.NAME || 'world';

    console.debug(`Hello ${NAME}!`);
}

main();
