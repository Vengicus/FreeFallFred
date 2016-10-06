//
//  clouds.swift
//  Free_Fall_Fred
//
//  Created by igmstudent on 3/7/16.
//  Copyright © 2016 Schwarting_Schoolnick. All rights reserved.
//

import Foundation
import SpriteKit

class Clouds
{
    var maxSpd:CGFloat = 100
    var velocity:CGVector = CGVector(dx: 0, dy: 0)
    var position:CGPoint = CGPointMake(0.0, 0.0)
    
    var cloud:SKSpriteNode!
    var bounds:CGRect!
    
    init(pos:CGPoint, bounds:CGRect)
    {
        position = pos
        self.bounds = bounds
    }
    convenience init(bounds:CGRect)
    {
        self.init(pos: CGPoint(x: CGFloat.random() * bounds.width, y: CGFloat.random() * -bounds.height / 2), bounds: bounds)
    }

    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCloud(imageName:String, name:String)
    {
        cloud = SKSpriteNode(imageNamed: "\(imageName)")
        cloud.alpha = CGFloat.random()
        cloud.name = "\(name)"
        cloud.position = position
        cloud.zPosition = GameLayer.Sprite
    }
    func moveCloud(dt: CGFloat)
    {
        //velocity.dy += accel.dy
        cloud.position += velocity * dt
        cloud.position.y += velocity.dy * dt
        if(cloud.position.x < 0)
        {
            cloud.position.x = 0
        }
        if(cloud.position.x > bounds.width)
        {
            cloud.position.x = bounds.width
        }
    }
    
    
}