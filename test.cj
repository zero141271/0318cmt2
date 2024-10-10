/*
 * This benchmark has been rewritten in Cangjie language based on benchmarksgame
 *
 * The Computer Language Benchmarks Game
 * https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 *
 * LICENSE: 3-Clause BSD
 * https://benchmarksgame-team.pages.debian.net/benchmarksgame/license.html
 *
 * Description: Allocate and deallocate many many binary treesdad
 *
 */
from std import sync.*
from std import os.*
from std import convert.*
from std import collection.*

enum Tree {
    Empty | Node(Tree, Tree)
}

func itemCheck(tree: Tree): UInt32 {
    match (tree) {
        case Node(left, right) => return 1 + itemCheck(left) + itemCheck(right)
        case _ => return 1
    }
}

func bottomUpTree(depth: UInt32): Tree {
    if (depth > 0) {
        return Node(bottomUpTree(depth - 1), bottomUpTree(depth - 1))
    }
    return Empty
}

class AllResult {
    public var outBuff: Array<String>
    public var outSize: UInt32
    public init(maxDepth: UInt32, minDepth: UInt32) {
        outSize = UInt32(3) + (maxDepth - minDepth) / UInt32(2)
        outBuff = Array<String>(Int64(outSize), item: "")
    }
}

func Run(maxDepth_: UInt32) {
    var maxDepth__ = maxDepth_
    let minDepth = UInt32(4)
    if (maxDepth__ < minDepth + UInt32(2)) {
        maxDepth__ = minDepth + UInt32(2)
    }
    let maxDepth = maxDepth__
    let x = AllResult(maxDepth, minDepth)

    var futures = ArrayList<Future<Unit>>()
    var f1 = spawn {
        var tree = bottomUpTree(maxDepth + UInt32(1))
            var msg = "stretch tree of depth ${maxDepth+1}\t check: ${itemCheck(tree)}"
            x.outBuff[0] = msg
    }
    futures.append(f1)

    var f2 = spawn {
        var longLivedTree = bottomUpTree(maxDepth)
            var msg = "long lived tree of depth ${maxDepth}\t check: ${itemCheck(longLivedTree)}"
            x.outBuff[Int64(x.outSize) - 1] = msg
    }
    futures.append(f1)

    for (depth in minDepth..=maxDepth : 2) {
        let iterations = UInt32(1) << (maxDepth - depth + minDepth)

        var f_temp = spawn {
            var acc = UInt32(0)
                for (i in 0..iterations) {
                    var a = bottomUpTree(depth)
                    acc += itemCheck(a)
                }
                var msg = "${iterations}\t trees of depth ${depth}\t check: ${acc}"
                x.outBuff[Int64(depth) / 2 - 1] = msg
        }
        futures.append(f_temp)
    }
    for (f in futures) {
        f.getResult()
    }
    for (m in x.outBuff) {
        println(m)
    }
}

main(args: Array<String>) : Unit {

    var n = UInt32.tryParse(args[1])??UInt32(21)

    Run(n)
}