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

        asynNumberUnderControl()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

