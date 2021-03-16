//
//  NSPointerArray+Extension.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import Foundation

internal extension NSPointerArray {

    func forEach<T>(closure:(T)->Void) {
        for i in self.allObjects {
            if let t = i as? T {
                closure(t)
            }
        }
    }

    func removeAll(where match: (AnyObject)->Bool) {
        for i in (0..<self.count).reversed() {
            if let pointer = self.pointer(at: i) {
                let object = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
                if match(object) {
                    self.removePointer(at: i)
                }
            }else {
                self.removePointer(at: i)
            }
        }
    }

    func add(_ object: AnyObject) {
        //先查重复
        self.removeAll(where: {$0 === object})
        self.addPointer(Unmanaged.passUnretained(object).toOpaque())
    }

}
