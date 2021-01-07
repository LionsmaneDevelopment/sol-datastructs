import { assert } from 'chai';

import { randomData } from "../../utils"
import { TestArrayLibUIntContract, TestArrayLibUIntName, IListUIntInstance } from "../../artifacts"
import { configure } from "../../configure"

interface ArrayLibUIntTest {
    contract: TestArrayLibUIntContract,
    name: TestArrayLibUIntName
}

async function equalArray(list: IListUIntInstance, expected: number[]) {
    const length = (await list.length()).toNumber()
    assert.equal(length, expected.length, "list.length() != expected.length")

    const promiseList = []

    for (let i = 0; i < length; i++) {
        promiseList.push(list.get(i));
    }

    const result = (await Promise.all(promiseList)).map((n) => n.toNumber())
    assert.deepEqual(result, expected, "[...contract.get()] != expected")
}

//push
//set
//swap
//remove
//length
//data

type WriteOpType = "PUSH" | "POP" | "SET" | "SWAP"
interface WriteOp {
    type: WriteOpType,
    i: number,
    j?: number
}
const WriteOpTypes: WriteOpType[] = ["PUSH", "POP", "SET", "SWAP"]


export function testArrayLib(test: ArrayLibUIntTest) {
    describe(test.name, function () {
        let list: IListUIntInstance;

        before(async () => {
            await configure()
        })

        beforeEach(async () => {
            list = await test.contract.new();

        })

        it("push() 100x", async () => {
            const expected = randomData(100)
            const promiseList = []
            for (let i of expected) {
                promiseList.push(list.push(i));
            }

            const results = (await Promise.all(promiseList)).map((r) => r.receipt.gasUsed - 20000)
            const total = results.reduce((acc, v) => acc + v, 0)
            const avg = total / results.length
            console.debug(`${test.name} avg: ${avg}`)

            await equalArray(list, expected)
        })

        it("push()/set()/swap()/pop() 100x", async () => {
            const expected: number[] = []
            const promiseList = []

            let length = 0; //bypass need to call length()
            for (let i = 0; i < 100; i++) {
                const writeType = WriteOpTypes[Math.floor(Math.random() * WriteOpTypes.length)]
                let writeIdx = length > 0 ? Math.floor(Math.random() * 65536 % length) : 0
                let writeVal = Math.floor(Math.random() * 65536)
                switch (writeType) {
                    case "PUSH":
                        promiseList.push(list.push(writeVal));
                        expected.push(writeVal)
                        length++
                        break
                    case "SET":
                        if (length < 1) break;
                        promiseList.push(list.set(writeIdx, writeVal));
                        expected[writeIdx] = writeVal
                        break
                    case "SWAP":
                        if (length < 2) break;
                        writeVal = writeVal % length
                        promiseList.push(list.swap(writeIdx, writeVal));
                        const t = expected[writeIdx]
                        expected[writeIdx] = expected[writeVal]
                        expected[writeVal] = t
                        break
                    case "POP":
                        if (length < 1) break;
                        promiseList.push(list.pop());
                        expected.pop()
                        length--
                        break
                }
            }

            const results = (await Promise.all(promiseList)).map((r) => r.receipt.gasUsed - 20000)
            const total = results.reduce((acc, v) => acc + v, 0)
            const avg = total / results.length
            console.debug(`${test.name} avg: ${avg}`)

            await equalArray(list, expected)
        })

    })
}
