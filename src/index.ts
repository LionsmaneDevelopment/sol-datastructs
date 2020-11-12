import dotenv from 'dotenv';

dotenv.config();

function main() {
    const NAME = process.env.NAME || 'world';

    console.debug(`Hello ${NAME}!`);
}

main();
