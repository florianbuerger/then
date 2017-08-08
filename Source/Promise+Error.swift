//
//  Promise+Error.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        tryStartInitialPromiseAndStartIfneeded()
        return registerOnError(block)
    }
    
    @discardableResult public func registerOnError(_ block: @escaping (Error) -> Void) -> Promise<Void> {
        let p = Promise<Void>()
        switch state {
        case .fulfilled:
            p.fulfill()
        // No error so do nothing.
        case let .rejected(error):
            // Already failed so call error block
            block(error)
            p.fulfill()
        case .dormant, .pending:
            // if promise fails, resolve error promise
            blocks.fail.append({ e in
                block(e)
                p.fulfill()
            })
            blocks.success.append({ _ in
                p.fulfill()
            })
            blocks.progress.append(p.setProgress)
        }
        p.start()
        passAlongFirstPromiseStartFunctionAndStateTo(p)
        return p
    }
}
