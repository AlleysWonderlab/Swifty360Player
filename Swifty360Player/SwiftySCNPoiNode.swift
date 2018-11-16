//
//  SwiftySCNPoiNode.swift
//  Swifty360Player
//
//  Created by seungsoo Lee on 14/11/2018.
//  Copyright © 2018 Abdullah Selek. All rights reserved.
//

import SceneKit

open class SwiftySCNPoiNode: SCNNode {
    
    public init(position: SCNVector3, eulerAngles: SCNVector3) {
        super.init()
        self.geometry = getGeometry()
        self.eulerAngles = eulerAngles
        self.position = position
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func getGeometry() -> SCNGeometry {
        let geometry = SCNPlane(width: 2, height: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "poi")
        geometry.cornerRadius = 1
        geometry.firstMaterial = material
        geometry.firstMaterial?.isDoubleSided = true
        return geometry
    }
}
