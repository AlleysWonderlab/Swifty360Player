//
//  Swifty360PlayerScene.swift
//  Swifty360Player
//
//  Copyright © 2017 Abdullah Selek. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SceneKit
import SpriteKit
import AVFoundation

open class Swifty360PlayerScene: SCNScene {

    public let camera = SCNCamera()
    private var videoPlaybackIsPaused: Bool!
    private var videoNode: SwiftySKVideoNode!
    private var cameraNode: SCNNode! {
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0.0, 0.0, 0.0)
        return cameraNode
    }
    private var forwardNode: SwiftySCNDirectionNode!
    private var backwardNode: SwiftySCNDirectionNode!
    private var leftNode: SwiftySCNDirectionNode!
    private var rightNode: SwiftySCNDirectionNode!
    private var player: AVPlayer!

    public init(withAVPlayer player: AVPlayer, view: SCNView) {
        super.init()
        self.videoPlaybackIsPaused = true
        self.player = player
        self.rootNode.addChildNode(self.cameraNode)
        let scene = getScene()
        videoNode = getVideoNode(withPlayer: self.player, scene: scene)
        scene.addChild(videoNode)
        self.rootNode.addChildNode(getSphereNode(scene: scene))
        view.scene = self
        view.pointOfView = cameraNode
        
        forwardNode = getDirectionNode(position: Node.Position.forward, eulerAngles: Node.Angle.forward)
        backwardNode = getDirectionNode(position: Node.Position.backward, eulerAngles: Node.Angle.backward)
        leftNode = getDirectionNode(position: Node.Position.left, eulerAngles: Node.Angle.left)
        rightNode = getDirectionNode(position: Node.Position.right, eulerAngles: Node.Angle.right)
        forwardNode.name = Node.Name.forward.rawValue
        backwardNode.name = Node.Name.backward.rawValue
        leftNode.name = Node.Name.left.rawValue
        rightNode.name = Node.Name.right.rawValue
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play() {
        videoPlaybackIsPaused = false
        player.play()
        videoNode.isPaused = false
    }

    func pause() {
        videoPlaybackIsPaused = true
        player.pause()
        videoNode.isPaused = true
    }
    
    func addDirectionNode(_ name: Node.Name) {
        switch name {
        case .forward:
            self.rootNode.addChildNode(self.forwardNode)
        case .backward:
            self.rootNode.addChildNode(self.backwardNode)
        case .left:
            self.rootNode.addChildNode(self.leftNode)
        case .right:
            self.rootNode.addChildNode(self.rightNode)
        }
    }
    
    func removeDirectionNode(_ name: Node.Name) {
        guard let node = self.rootNode.childNode(withName: name.rawValue, recursively: false) else {return}
        node.removeFromParentNode()
    }
    
    func addPoiNode(_ id: String, geo: (Double, Double, Double), eulerAngleY: Double) {
        let position = SCNVector3(geo.0, geo.1, geo.2)
        let angles = SCNVector3(0, eulerAngleY, 0)
        let poiNode = SwiftySCNPoiNode(position: position, eulerAngles: angles)
        poiNode.name = id
        self.rootNode.addChildNode(poiNode)
    }
    
    func removePoiNode(_ id: String) {
        guard let node = self.rootNode.childNode(withName: id, recursively: true) else {return}
        node.removeFromParentNode()
    }
    
    func updatePoiNode(_ id: String, position: (Double, Double, Double), eulerAngleY: Double) {
        guard let node = self.rootNode.childNode(withName: id, recursively: true) else {return}
        let newPosition = SCNVector3(position.0, position.1, position.2)
        let newAngles = SCNVector3(0, eulerAngleY, 0)
        node.position = newPosition
        node.eulerAngles = newAngles
    }
    
    func rotateRootNodeInit() {
        self.rootNode.eulerAngles = SCNVector3(0, 0, 0)
    }
    
    func rotateRootNodeToRight() {
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        SCNTransaction.animationDuration = 0.6
        SCNTransaction.begin()
        self.rootNode.eulerAngles = SCNVector3(0, Double(80) * .pi/180, 0)
        SCNTransaction.completionBlock = {
            SCNTransaction.animationDuration = 0
        }
        SCNTransaction.commit()
    }
    func rotateRootNodeToLeft() {
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        SCNTransaction.animationDuration = 0.6
        SCNTransaction.begin()
        self.rootNode.eulerAngles = SCNVector3(0, -Double(80) * .pi/180, 0)
        SCNTransaction.completionBlock = {
            SCNTransaction.animationDuration = 0
        }
        SCNTransaction.commit()
    }

    internal func getScene() -> SKScene {
        let assetTrack = player.currentItem?.asset.tracks(withMediaType: .video).first
        let assetDimensions = assetTrack != nil ? __CGSizeApplyAffineTransform(assetTrack!.naturalSize, assetTrack!.preferredTransform) :
            CGSize(width: 1280.0, height: 1280.0)
        let scene = SKScene(size: CGSize(width: fabsf(assetDimensions.width.getFloat()).getCGFloat(),
                                         height: fabsf(assetDimensions.height.getFloat()).getCGFloat()))
        scene.shouldRasterize = true
        scene.scaleMode = .aspectFit
        scene.addChild(getVideoNode(withPlayer: player, scene: scene))
        return scene
    }

    internal func getVideoNode(withPlayer player: AVPlayer, scene: SKScene) -> SwiftySKVideoNode {
        let videoNode = SwiftySKVideoNode(avPlayer: player)
        videoNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        videoNode.size = scene.size
        videoNode.yScale = -1
        videoNode.xScale = -1
        videoNode.swiftyDelegate = self
        return videoNode
    }

    internal func getSphereNode(scene: SKScene) -> SCNNode {
        let sphereNode = SCNNode()
        sphereNode.position = SCNVector3Make(0.0, 0.0, 0.0)
        sphereNode.geometry = SCNSphere(radius: 100.0)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = scene
        sphereNode.geometry?.firstMaterial?.diffuse.minificationFilter = .linear
        sphereNode.geometry?.firstMaterial?.diffuse.magnificationFilter = .linear
        sphereNode.geometry?.firstMaterial?.isDoubleSided = true
        return sphereNode
    }
    
    internal func getDirectionNode(position: SCNVector3, eulerAngles: SCNVector3) -> SwiftySCNDirectionNode {
        let node = SwiftySCNDirectionNode(position: position, eulerAngles: eulerAngles)
        node.geometry = getGeometry()
        return node
    }
    
    internal func getGeometry() -> SCNGeometry {
        let geometry = SCNPlane(width: 2, height: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "play-button")
        geometry.firstMaterial = material
        geometry.firstMaterial?.isDoubleSided = true
        return geometry
    }

}

extension Swifty360PlayerScene: SwiftySKVideoNodeDelegate {

    public func videoNodeShouldAllowPlaybackToBegin(videoNode: SwiftySKVideoNode) -> Bool {
        return !self.videoPlaybackIsPaused
    }

}
