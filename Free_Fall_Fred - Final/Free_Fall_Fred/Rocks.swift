//
//  Rocks.swift
//  Free_Fall_Fred
//
//  Created by igmstudent on 3/7/16.
//  Copyright © 2016 Schwarting_Schoolnick. All rights reserved.
//
import Foundation
import SpriteKit
class Rocks : SKSpriteNode
{
    
    var orientation = [Int:[String:CGFloat]]()
    //TODO: MAKE POSITION MATCH ACCORDING TO APPROPRIATE LOCATION
    //ORIENTATION 0 = LEFT SIDE, ORIENTATION 1 = RIGHT SIDE OF SCREEN
    init(sideOfScrn:Int, yPos:CGFloat, bounds:CGRect)
    {
        let rock = SKTexture(imageNamed: "rock01")
        orientation[0] = ["xPos": 250, "yPos": yPos, "size": -2.0]
        orientation[1] = ["xPos": bounds.size.width, "yPos": yPos, "size": 2.0]
        
        super.init(texture: rock, color: UIColor.clearColor(), size: rock.size())
        name = "rock"
        position = CGPoint(x: orientation[sideOfScrn]!["xPos"]!, y: orientation[sideOfScrn]!["yPos"]!)
        size.width *= orientation[sideOfScrn]!["size"]!
        size.height *= abs(orientation[sideOfScrn]!["size"]!)
        zPosition = 100
    }
    /*convenience init(bounds:CGRect)
    {
        self.init(pos: CGPoint(x: CGFloat.random() * bounds.width, y: CGFloat.random() * -bounds.height / 2), bounds: bounds)
    }*/
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}
