//
//  GameOverScene.swift
//  Free_Fall_Fred
//
//  Created by igmstudent on 2/29/16.
//  Copyright © 2016 Schwarting_Schoolnick. All rights reserved.
//

import Foundation
import SpriteKit

//MARK: GAMEOVER Scene
class GameOverScene: SKScene
{
    override init(size: CGSize)
    {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.whiteColor()
        
        // 2
        let message = "You Lost"
        
        // 3
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}