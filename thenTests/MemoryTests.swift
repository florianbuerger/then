//
//  MemoryTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 09/08/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
@testable import then

class MemoryTests: XCTestCase {
    
    func testRaceConditionWriteState() {
        let p = Promise<String>()
        
        func loopState() {
            for i in 0...10000 {
                p.updateState(PromiseState<String>.fulfilled(value: "Test1-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test2-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test3-\(i)"))
            }
        }
        
        if #available(iOS 10.0, *) {
            let t1 = Thread { loopState() }
            let t2 = Thread { loopState() }
            let t3 = Thread { loopState() }
            let t4 = Thread { loopState() }
            t1.start()
            t2.start()
            t3.start()
            t4.start()
        } else {
            // Fallback on earlier versions
        }
        loopState()
    }
    
    func testRaceConditionReadState() {
        let p = Promise(value: "Hello")
        
        func loopState() {
            for i in 0...10000 {
                p.updateState(PromiseState<String>.fulfilled(value: "Test1-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test2-\(i)"))
                p.updateState(PromiseState<String>.fulfilled(value: "Test3-\(i)"))
                //Access Value
                let value = p.value
                print(value ?? "")
            }
        }
        
        if #available(iOS 10.0, *) {
            let t1 = Thread { loopState() }
            let t2 = Thread { loopState() }
            let t3 = Thread { loopState() }
            let t4 = Thread { loopState() }
            t1.start()
            t2.start()
            t3.start()
            t4.start()
        } else {
            // Fallback on earlier versions
        }
        loopState()
    }
    
    func testRaceConditionWriteWriteBlocks() {
        let p = Promise<String>()
        func loop() {
            for _ in 0...10000 {
                p.blocks.success.append({ _ in })
                p.blocks.fail.append({ _ in })
                p.blocks.progress.append({ _ in })
                p.blocks.finally = { }
            }
        }
        if #available(iOS 10.0, *) {
            let t1 = Thread { loop() }
            let t2 = Thread { loop() }
            let t3 = Thread { loop() }
            let t4 = Thread { loop() }
            t1.start()
            t2.start()
            t3.start()
            t4.start()
        } else {
            // Fallback on earlier versions
        }
        loop()
    }
    
    func testRaceConditionWriteReadBlocks() {
        let p = Promise<String>()
        p.blocks.success.append({ _ in })
        p.blocks.fail.append({ _ in })
        p.blocks.progress.append({ _ in })
        p.blocks.success.append({ _ in })
        p.blocks.fail.append({ _ in })
        p.blocks.progress.append({ _ in })
        p.blocks.finally = { }
        
        func loop() {
            for _ in 0...10000 {
                
                for sb in p.blocks.success {
                    sb("YO")
                }
                
                for fb in p.blocks.fail {
                    fb(PromiseError.default)
                }
                
                for p in p.blocks.progress {
                    p(0.5)
                }
                
                p.blocks.finally()
            }
        }
        if #available(iOS 10.0, *) {
            let t1 = Thread { loop() }
            let t2 = Thread { loop() }
            let t3 = Thread { loop() }
            let t4 = Thread { loop() }
            t1.start()
            t2.start()
            t3.start()
            t4.start()
        } else {
            // Fallback on earlier versions
        }
        loop()
    }
}
