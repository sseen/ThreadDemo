//
//  ViewController.swift
//  ThreadDemo
//
//  Created by sseen on 2017/12/21.
//  Copyright © 2017年 sseen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let list = [Int](100...110)
        let queueSerial = DispatchQueue(label: "com.one.serial", qos: .userInitiated)
        let queueConcurrent = DispatchQueue(label: "com.one.concurrent", qos: .userInitiated, attributes: .concurrent)
        list.enumerated().forEach({ (offset, element) in
            queueSerial.async {
                queueConcurrent.async {
                    print("\(Thread.current) ",element)
                }
            }
        })
        
        let semaphore = DispatchSemaphore(value: 2)
        let group = DispatchGroup()
        
        list.enumerated().forEach({ (offset, element) in
            semaphore.wait()
            group.enter()
            queueSerial.async {
                queueConcurrent.async {
                    print("\(Thread.current)- ",element)
                    sleep(3)
                    queueConcurrent.async {
                        print("\(Thread.current)* ",element)
                        sleep(3)
                    }
                    print("\(Thread.current)+ ",element)
                    // group.leave()
                    semaphore.signal()
                }
                group.leave()
            }
        })
        
        group.notify(queue: .main) {
            // Can run before syncTask1 completes - DON'T DO THIS
            print("complete")
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queueConcurrent() {
        let queueConcurrent = DispatchQueue(label: "com.one.concurrent", qos: .userInitiated, attributes: .concurrent)
        queueConcurrent.sync {
            print("outside \t \(Thread.current)")
            queueConcurrent.sync {
                print("inside \t \(Thread.current)")
                let list = [Int](40...60)
                list.enumerated().forEach{
                    print("\($0) : \($1)")
                }
            }
            let list = [Int](1...20)
            list.enumerated().forEach{
                print("\($0) : \($1)")
            }
        }
        print("outside \t \(Thread.current)")
        
        queueConcurrent.async {
            print("outside \t \(Thread.current)")
            queueConcurrent.sync {
                print("inside \t \(Thread.current)")
                let list = [Int](40...60)
                list.enumerated().forEach{
                    print("\($0) : \($1)")
                }
            }
            let list = [Int](1...20)
            list.enumerated().forEach{
                print("\($0) : \($1)")
            }
        }
        print("--outside \t \(Thread.current)")
        
        queueConcurrent.sync {
            print("outside \t \(Thread.current)")
            queueConcurrent.async {
                print("inside \t \(Thread.current)")
                let list = [Int](40...60)
                list.enumerated().forEach{
                    print("\($0) : \($1)")
                }
            }
            let list = [Int](1...20)
            list.enumerated().forEach{
                print("\($0) : \($1)")
            }
        }
        print("**outside \t \(Thread.current)")
    }
    
    func queueSerial() {
        // 串行队列，同步任务
        let queueSerial = DispatchQueue(label: "com.one.serial", qos: .userInitiated)
        queueSerial.sync {
            print("inside \t \(Thread.current)")
        }
        print("outside \t \(Thread.current)")
        
        // 串行，同步套异步
        queueSerial.sync {
            print("outside \t \(Thread.current)")
            // 串行队列，同步任务嵌套，报错永远无法执行inside方法，
            // 因为外层同步任务阻塞串行队列，内部同步任务无法执行，因为外部的同步任务还没有执行结束，♻️
            // queueSerial.sync {
            // 内部的异步
            queueSerial.async {
                print("inside \t \(Thread.current)")
            }
            let list = [Int](1...20)
            list.enumerated().forEach{
                print("\($0) : \($1)")
            }
        }
        print("outside \t \(Thread.current)")
        
        // 串行，异步套同步
        queueSerial.async {
            print("outside \t \(Thread.current)")
            // 内层同步任务不能执行，以为异步任务已经开始，在串行队列里，任务没有执行完毕是不会开启另一个任务的
            // queueSerial.sync {
            queueSerial.async {
                print("inside \t \(Thread.current)")
            }
            let list = [Int](1...20)
            list.enumerated().forEach{
                print("\($0) : \($1)")
            }
        }
        print("outside \t \(Thread.current)")
    }
    
    func asynNumberUnderControl() {
        //        dispatch_queue_t workConcurrentQueue = dispatch_queue_create("cccccccc", DISPATCH_QUEUE_CONCURRENT);
        //        dispatch_queue_t serialQueue = dispatch_queue_create("sssssssss",DISPATCH_QUEUE_SERIAL);
        //        dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
        //
        //        for (NSInteger i = 0; i < 10; i++) {
        //            dispatch_async(serialQueue, ^{
        //                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //                dispatch_async(workConcurrentQueue, ^{
        //                    NSLog(@"thread-info:%@开始执行任务%d",[NSThread currentThread],(int)i);
        //                    sleep(1);
        //                    NSLog(@"thread-info:%@结束执行任务%d",[NSThread currentThread],(int)i);
        //                    dispatch_semaphore_signal(semaphore);});
        //                });
        //        }
        //        NSLog(@"主线程...!");
        
        let queueConcurrent = DispatchQueue(label: "com.one", qos: .userInitiated, attributes: .concurrent)
        let queueSerial = DispatchQueue(label: "com.one.serial", qos: .userInitiated)
        
        let semaphore = DispatchSemaphore(value: 3)
        let additionalTime: DispatchTimeInterval = .seconds(2)
        for i in 0..<10 {
            queueSerial.asyncAfter(deadline: .now() + additionalTime, execute: {
                semaphore.wait(timeout: .distantFuture)
                queueConcurrent.async {
                    print("\(Thread.current)",i)
                    sleep(2);
                    semaphore.signal()
                }
            })
        }
    }
    
    func asynNumberNotControl() {
        let queue = DispatchQueue(label: "com.one", qos: .userInitiated, attributes: .concurrent)
        
        print(Date())
        let additionalTime: DispatchTimeInterval = .seconds(2)
        queue.asyncAfter(deadline: .now() + additionalTime, execute: {
            
            for i in 100..<110 {
                print("\(Thread.current)🔴",i)
                print("\(Thread.current)🔴\(i)_",i)
            }
            
            print("\(Thread.current)",Date())
        })
        
        queue.asyncAfter(deadline: .now() + additionalTime, execute: {
            for i in 100..<110 {
                print("\(Thread.current)🔶",i)
            }
            print("\(Thread.current)",Date())
        })
        queue.asyncAfter(deadline: .now() + additionalTime, execute: {
            for i in 1000..<1010 {
                print("\(Thread.current)💎",i)
            }
            print("\(Thread.current)",Date())
        })
        
        var value = 10
        
        let workItem = DispatchWorkItem {
            print("\(Thread.current)")
            value += 5
        }
        
        workItem.perform()
        
        let queue2 = DispatchQueue.global(qos: .utility)
        
        queue2.async(execute: workItem)
        
        workItem.notify(queue: DispatchQueue.main) {
            print("\(Thread.current) value = ", value)
        }
    }

}

