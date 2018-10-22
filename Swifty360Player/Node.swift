//
//  Node.swift
//  Swifty360Player
//
//  Created by seungsoo Lee on 22/10/2018.
//  Copyright © 2018 Abdullah Selek. All rights reserved.
//

import Foundation
import SceneKit

public enum Node {
    
    static func radian(degree: Int) -> Double {
        return Double(degree) * .pi/180
    }
    
    enum Name: String {
        case forward = "foward_node"
        case left = "left_node"
        case right = "right_node"
        case backward = "backward_node"
    }
    
    enum Position {
        static let forward = SCNVector3(0, -7, -10.2)
        static let left = SCNVector3(2, -7, -9)
        static let right = SCNVector3(-2, -7, -9)
        static let backward = SCNVector3(0, -7, -7.8)
    }
    
    enum Angle {
        static let forward = SCNVector3(radian(degree: 90), radian(degree: 180), 0)
        static let left = SCNVector3(radian(degree: 90), radian(degree: 90), 0)
        static let right = SCNVector3(radian(degree: 90), radian(degree: 270), 0)
        static let backward = SCNVector3(radian(degree: 90), 0, 0)
    }
}
