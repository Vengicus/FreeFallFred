//
//  MyUtils.swift
//  Free_Fall_Fred
//
//  Created by igmstudent on 2/29/16.
//  Copyright © 2016 Schwarting_Schoolnick. All rights reserved.
//

import Foundation
import SpriteKit

struct GameLayer
{
    static let Background: CGFloat = 0
    static let HUD       : CGFloat = 1
    static let Sprite    : CGFloat = 2
    static let Message   : CGFloat = 3
}

struct PhysicsCategory
{
    static let None     : UInt32 = 0
    static let All      : UInt32 = UInt32.max
    static let Enemy    : UInt32 = 0b1
    static let Ground   : UInt32 = 0b10
    static let Player   : UInt32 = 0b11
}

struct GAME_STATE
{
    static let GAME_PLAYING:Int32   = 0
    static let ROUND_OVER:Int32     = 1
    static let GAME_OVER:Int32      = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //Music
    let splat = SKAction.playSoundFileNamed("fall.wav", waitForCompletion: false)
    let bMusic = SKAction.playSoundFileNamed("enchanted tiki 86.mp3", waitForCompletion: false)
    let winMusic = SKAction.playSoundFileNamed("chipquest.wav", waitForCompletion: false)
    
    
    // MARK: ivars
    var gameState:Int32 = 0
    
    var top:CGFloat = 0, bottom:CGFloat = 0, left:CGFloat = 0, right:CGFloat = 0
    var playableRect:CGRect = CGRectZero
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    var player:Player!
    var cloudObjects:[Clouds] = []
    var rockObjects:[Rocks] = []
    
    var playerVelocity:CGFloat = 25
    
    var viewController: GameViewController!
    
    var background:SKSpriteNode!
    
    var touchesMoved = false
    
    // MARK: Actions
    var playerAnimation: SKAction?
    
    //rock properties
    var rockBounds:CGRect = CGRectZero
    var numRocks:Int = 0
    var topOfRocks:CGFloat = 0
    
    // camera
    var cameraPosition:CGPoint!
    var screenScroller:SKSpriteNode!
    let cameraNode = SKCameraNode()
    let cameraMovementPerSec:CGFloat = 25
    
    //distance
    var distanceLabel:SKLabelNode!
    var distToBottom:CGFloat = 0
    
    var roundOverLabel:SKLabelNode!
    
    var control:TWButton!
    
    //slow down player
    var decel:CGFloat = 350
    var buttonPressed:Bool = false
    var decelerate = false
    var playerCanMove = true
    
    override init(size:CGSize) {
        super.init(size: size)
        self.buildPlayer()
        print(player.position)
        runAction(bMusic)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization -
    override func didMoveToView(view: SKView)
    {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        cameraPosition = CGPoint(x: size.width/2, y: CGFloat(-1500 * level))
        setupUI()
        makeSprites()
        addChild(cameraNode)
        camera = cameraNode
        setCameraPosition(cameraPosition)
    }
    
    // MARK: - Helpers -
    func setupUI()
    {
        // calculate playable rect for iPhone 4S
        top = is4SorOlder() ? size.height - 150 : size.height
        bottom = is4SorOlder() ? 150 : 0
        left = 0
        right = size.width
        playableRect = CGRectMake(0, bottom, size.width, top)
        
        screenScroller = SKSpriteNode()
        screenScroller.position = CGPoint(x: 0, y: 0)
        
        backgroundColor = SKColor.blackColor()
        background = SKSpriteNode(imageNamed: "background_clouds_3")
        background.alpha = CGFloat(1/(CGFloat(level) * 0.2))
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: -background.size.height/2 - size.height)
        background.zPosition = GameLayer.Background
        screenScroller.addChild(background)
        
        rockBounds = CGRectMake(150, -background.size.height + size.height / 2, size.width - 300, background.size.height + top)
        //drawDebugBorder(rockBounds)
        
        self.control?.removeFromParent()
        self.distanceLabel?.removeFromParent()
        self.roundOverLabel?.removeFromParent()
        
        //check game state and start playing
        if(gameState == GAME_STATE.GAME_PLAYING)
        {
            //button
            control = TWButton(size: CGSize(width: 455, height: 110), normalColor: SKColor(red: 225, green: 225, blue: 225, alpha: 0.5), selectedColor: SKColor.whiteColor(), singleHighlightedColor: SKColor(red: 225, green: 225, blue: 225, alpha: 0.75), disabledColor: SKColor(red: 225, green: 225, blue: 225, alpha: 0.15))
            control.name = "land"
        
            control.position = CGPoint(x: CGRectGetMidX(self.frame) - 540, y: CGRectGetMidY(self.frame) - 1150)
            control.setNormalStateLabelText("LAND")
            control.setNormalStateLabelFontColor(SKColor(red: 25, green: 25, blue: 25, alpha: 1.0))
        
            control.setHighlightedStateSingleLabelText("LAND")
            control.setHighlightedStateSingleLabelFontColor(SKColor(red: 225, green: 225, blue: 225, alpha: 1.0))
        
            control.setDisabledStateLabelText("LAND")
            control.setDisabledStateLabelFontColor(SKColor(red: 225, green: 225, blue: 225, alpha: 0.35))
        
            control.setAllStatesLabelFontName("PassionOne-Regular")
            control.setAllStatesLabelFontSize(80)
            control.zPosition = 1100
            control.addClosure(.TouchUpInside, target: self, closure: { (scene, sender) -> () in
                self.player.releaseParachute(self.playableRect)
                self.player.texture = SKTexture(imageNamed: "PLAYERSTANDING")
                self.player.setScale(0.65)
                self.player.size.width = self.player.size.width / 1.35
                //print("player z position b4 : \(self.player.zPosition)")
                self.control.removeFromParent()
                self.buttonPressed = true
            })
            //self.player.zPosition = 5
            print("player z position : \(player.zPosition)")
            control.enabled = false
            cameraNode.addChild(control)
            
            //distance shit
            self.distanceLabel = SKLabelNode(fontNamed: "PassionOne-Regular")
            self.distanceLabel.text = "Distance to Bottom: 0 yards"
            self.distanceLabel.fontSize = 40
            self.distanceLabel.fontColor = SKColor.whiteColor()
            self.distanceLabel.position = CGPoint(x: 0, y: -100)
            self.distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            self.distanceLabel.zPosition = 1100
            self.cameraNode.addChild(self.distanceLabel)
        }
        
        //round over state
        if(gameState == GAME_STATE.ROUND_OVER)
        {
            self.roundOverLabel = SKLabelNode(fontNamed: "PassionOne-Regular")
            self.roundOverLabel.text = "Round Over! Get ready for level \(level + 1). Tap for next level."
            self.roundOverLabel.fontSize = 30
            self.roundOverLabel.fontColor = SKColor.whiteColor()
            self.roundOverLabel.position = CGPoint(x: 0, y: -100)
            self.roundOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            self.roundOverLabel.zPosition = 1100
            self.cameraNode.addChild(self.roundOverLabel)
        }
        else if(gameState == GAME_STATE.GAME_OVER)
        {
            self.roundOverLabel = SKLabelNode(fontNamed: "PassionOne-Regular")
            self.roundOverLabel.text = "Game over. Tap to return to menu"
            self.roundOverLabel.fontSize = 60
            self.roundOverLabel.fontColor = SKColor.whiteColor()
            self.roundOverLabel.position = CGPoint(x: 0, y: -100)
            self.roundOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            self.roundOverLabel.zPosition = 1100
            self.cameraNode.addChild(self.roundOverLabel)
        }
        
        numRocks = level * 2
        
        
        print("background.size=\(background.size)")
        print("playableRect=\(playableRect.size)")
        print("screen aspect ratio=\(getScreenAspectRatio())")
        print("is4SorOlder=\(is4SorOlder())")
        
    }
    
    // MARK: - Game Loop -
    override func update(currentTime: NSTimeInterval)
    {
        calculateDeltaTime(currentTime)
        if(cameraNode.position.y < player.position.y - size.height/3)
        {
            cameraNode.position.y += 10
            distToBottom += 2
            if(self.distanceLabel != nil)
            {
                self.distanceLabel.text = "Distance to Bottom: \(Int(distToBottom)) yards"
            }
        }
        else
        {
            if(playerCanMove) //if player can move is true
            {
                movePlayer(CGFloat(dt))
                if(decelerate == false) //if player is not moving down accelerating
                {
                    moveScene(CGFloat(dt))
                }
                cameraNode.position.y = player.position.y - size.height/3
            
                distToBottom -= CGFloat(playerVelocity * 0.2)
                if(distToBottom % 100 == 0)
                {
                    let actionPulse = SKAction.scaleBy(1.15, duration: 0.2)
                    let actionReversePulse = SKAction.reversedAction(actionPulse)
                    //let actionRemove = SKAction.removeFromParent()
                    distanceLabel.runAction(SKAction.sequence([actionPulse, actionReversePulse()]))
                }
                if(distToBottom < 200) //if distance to bottom is less than 200 show the land button
                {
                    control.enabled = true
                    if(buttonPressed == false && distToBottom <= 10)
                    {
                        self.player.destroy()
                        decelerate = true
                        distToBottom = 0
                        gameState = GAME_STATE.GAME_OVER
                        setupUI()
                    }
                }
                if(distToBottom < 50) // if they havent hit the button before 50 yards they die
                {
                    control.removeFromParent()
                }
                if(self.distanceLabel != nil)
                {
                    self.distanceLabel.text = "Distance to Bottom: \(Int(distToBottom)) yards"
                }
            }
        }
        if(buttonPressed) //when button is pressed
        {
            decelerate = true
            if(decel > 0)
            {
                decel -= 1
            }
            if(distToBottom < 1)
            {
                distToBottom = 0
                runAction(winMusic)
            }
            slowMoveScene(CGFloat(dt), decel: CGFloat(decel))
            //print(decel)
        }
        
    }
    // Mark: debug and collision
    func drawDebugBorder(rect:CGRect)
    {
        let bound = SKShapeNode(rect: rect)
        bound.strokeColor = SKColor.redColor()
        bound.position = CGPoint(x: 0, y: 0)
        bound.zPosition = 1000
        addChild(bound)
    }
    
    func playerCollidedElse(player:SKSpriteNode, other:SKSpriteNode)
    {
        print("COLLIDED")
        runAction(splat)
        playerCanMove = false
        self.player.destroy()
        gameState = GAME_STATE.GAME_OVER
        setupUI()
    }
    
    //MARK: -Create Sprites-
    func makeSprites()
    {
        addChild(screenScroller)
        buildGround()
        buildClouds()
        buildRocks()
        buildBirds()
    }
    
    func buildPlayer()
    {
        print(playableRect)
        player = Player(screen: CGSize(width: playableRect.width, height: playableRect.height),  pos: CGPoint(x: playableRect.width/2 + 600, y: playableRect.height / 2 + 300), hp: 3)
        player.zPosition = 102
        player.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        //playerObj.createSprite("player", name: "player")
        addChild(player)
    }
    
    func buildClouds()
    {
        for _ in 0..<10
        {
            cloudObjects.append(Clouds(bounds: CGRect(x: background.position.x, y: background.position.y, width: background.size.width, height: background.size.height)))
            
        }
        for cloud in cloudObjects
        {
            cloud.createCloud("cloud", name: "cloud")
            screenScroller.addChild(cloud.cloud)
        }
    }
    func buildRocks()
    {
        buildCliffSide()
        //var side = 1
        var yPos:CGFloat = topOfRocks - 300
        for _ in 1...numRocks
        {
            rockObjects.append(Rocks(sideOfScrn: Int(CGFloat.random() * 2), yPos: yPos, bounds: rockBounds))
            yPos -= CGFloat(200 * (maxLevels - level + 1))
            
            /*if(side / 1 == 0)
            {
                side = 1
            }
            else
            {
                side = 0
            }*/
            //rockObjects.append(Rocks(sideOfScrn: Int(CGFloat.random() * 2), yPos: (CGFloat.random(min: rockBounds.height * -1, max: topOfRocks)), bounds: rockBounds))
        }
        for rock in rockObjects
        {
            rock.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 400, height: 200))
            rock.physicsBody?.dynamic = true
            rock.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
            //rock.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            rock.physicsBody?.collisionBitMask = PhysicsCategory.None
            rock.physicsBody?.usesPreciseCollisionDetection = true
            screenScroller.addChild(rock)
        }
    }
    func buildGround()
    {
        let ground:SKSpriteNode = SKSpriteNode(imageNamed: "grass")
        ground.name = "ground"
        ground.position = CGPoint(x: cameraPosition.x, y: cameraPosition.y - 160)
        ground.size.width *= 3
        ground.size.height *= 20.0
        ground.zPosition = 101
        //ground.alpha = CGFloat(1/(CGFloat(level) * 0.5))
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: ground.size.width, height: ground.size.height))
        ground.physicsBody?.dynamic = true
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.None
        ground.physicsBody?.usesPreciseCollisionDetection = true
        screenScroller.addChild(ground)
    }
    func buildCliffSide()
    {
        //let cliffSideLeft:SKSpriteNode = SKSpriteNode(imageNamed: "cliffSide_Tileable")
        for i in 1...level+1
        {
            if(i < level+1)
            {
                let cliffSideLeft:SKSpriteNode = SKSpriteNode(imageNamed: "cliffSide_Tileable")
                cliffSideLeft.name = "cliff"
                cliffSideLeft.position = CGPoint(x: 200, y: (cameraPosition.y - 325) + CGFloat(i * 800))
                cliffSideLeft.size.height *= 2
                cliffSideLeft.size.width *= -1
                cliffSideLeft.zPosition = 103
                cliffSideLeft.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 200, height: cliffSideLeft.size.height), center: CGPoint(x: -100, y: 0))
                cliffSideLeft.physicsBody?.dynamic = false
                cliffSideLeft.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
                //cliffSideLeft.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                cliffSideLeft.physicsBody?.collisionBitMask = PhysicsCategory.None
                cliffSideLeft.physicsBody?.usesPreciseCollisionDetection = true
                
                let cliffSideRight:SKSpriteNode = SKSpriteNode(imageNamed: "cliffSide_Tileable")
                cliffSideRight.name = "cliff"
                cliffSideRight.position = CGPoint(x: rockBounds.width + 100, y: (cameraPosition.y - 325) + CGFloat(i * 800))
                cliffSideRight.size.height *= 2
                cliffSideRight.zPosition = 103
                cliffSideRight.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 200, height: cliffSideRight.size.height), center: CGPoint(x: 100, y: 0))
                cliffSideRight.physicsBody?.dynamic = false
                cliffSideRight.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
                //cliffSideRight.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                cliffSideRight.physicsBody?.collisionBitMask = PhysicsCategory.None
                cliffSideRight.physicsBody?.usesPreciseCollisionDetection = true
                
                screenScroller.addChild(cliffSideLeft)
                screenScroller.addChild(cliffSideRight)
                
            }
            else
            {
                let cliffSideLeftTop:SKSpriteNode = SKSpriteNode(imageNamed: "cliffSide_Top")
                cliffSideLeftTop.name = "cliff"
                cliffSideLeftTop.position = CGPoint(x: 200, y: (cameraPosition.y - 358) + CGFloat(i * 800))
                cliffSideLeftTop.size.height *= 1
                cliffSideLeftTop.size.width *= -1
                cliffSideLeftTop.zPosition = 103
                cliffSideLeftTop.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 200, height: 200), center: CGPoint(x: -100, y: -150))
                cliffSideLeftTop.physicsBody?.dynamic = false
                cliffSideLeftTop.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
                //cliffSideLeftTop.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                cliffSideLeftTop.physicsBody?.collisionBitMask = PhysicsCategory.None
                cliffSideLeftTop.physicsBody?.usesPreciseCollisionDetection = true
                
                let cliffSideRightTop:SKSpriteNode = SKSpriteNode(imageNamed: "cliffSide_Top")
                cliffSideRightTop.name = "cliff"
                cliffSideRightTop.position = CGPoint(x: rockBounds.width + 100, y: (cameraPosition.y - 358) + CGFloat(i * 800))
                cliffSideRightTop.size.height *= 1
                cliffSideRightTop.size.width *= 1
                cliffSideRightTop.zPosition = 103
                cliffSideRightTop.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 200, height: 200), center: CGPoint(x: 100, y: -150))
                cliffSideRightTop.physicsBody?.dynamic = false
                cliffSideRightTop.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
                //cliffSideRightTop.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                cliffSideRightTop.physicsBody?.collisionBitMask = PhysicsCategory.None
                cliffSideRightTop.physicsBody?.usesPreciseCollisionDetection = true
                
                screenScroller.addChild(cliffSideLeftTop)
                screenScroller.addChild(cliffSideRightTop)
                
                topOfRocks = cliffSideLeftTop.position.y
                
                
            }
        }
    }
    func buildBirds()
    {
        for _ in 1...level+1
        {
            let bird = SKSpriteNode(imageNamed: "bird01")
            bird.name = "bird"
            bird.position = CGPoint(x: CGFloat.random(min: 0, max: playableRect.width), y: CGFloat.random(min: CGFloat(-800 * level), max: 0))
            bird.zPosition = 1000
            bird.physicsBody = SKPhysicsBody(circleOfRadius: 50)
            bird.physicsBody?.dynamic = false
            bird.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
            bird.physicsBody?.collisionBitMask = PhysicsCategory.None
            bird.physicsBody?.usesPreciseCollisionDetection = true
            screenScroller.addChild(bird)
            
            var inverse = Int(CGFloat.random())
            if(inverse == 0)
            {
                inverse = -1
            }
            let actionMove = SKAction.moveByX(playableRect.width * CGFloat.random() * CGFloat(inverse), y: 0, duration: 1.5)
            let actionReverseMove = actionMove.reversedAction()
            bird.runAction(SKAction.repeatActionForever(SKAction.sequence([actionMove, actionReverseMove])))
        }
    }
    
    
    func calculateDeltaTime(currentTime: NSTimeInterval)
    {
        if lastUpdateTime > 0
        {
            dt = currentTime - lastUpdateTime
        }
        else
        {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    func calculateDistToBottom() -> CGFloat
    {
        return 0
    }
    
    //MARK: -Move Sprites -
    //move the player
    func movePlayer(dt:CGFloat)
    {
        //var xVelocity = gravityVector.x * 2
        //xVelocity = xVelocity < -1 ? -1 : xVelocity // -1.0 = 45 degrees left rotation
        //xVelocity = xVelocity > 1 ? 1 : xVelocity // +1.0 = 45 degrees right rotation
        
        //bounds check
        // future postion
                                //player.position V
        player.boundsCheckPlayer(playableRect)
        player.move(dt, bounds: playableRect)
    }
    
    func moveScene(dt:CGFloat)
    {
        playerVelocity = (playerVelocity + 350) * dt // 350
        screenScroller.runAction(SKAction.moveBy(CGVector(dx: 0, dy: playerVelocity), duration: 0.001))
    }
    func slowMoveScene(dt:CGFloat, decel:CGFloat)
    {
        playerVelocity = (playerVelocity + decel) * dt // 350
        screenScroller.runAction(SKAction.moveBy(CGVector(dx: 0, dy: playerVelocity), duration: 0.001))
        if(distToBottom <= 0)
        {
            playerCanMove = false
            gameState = GAME_STATE.ROUND_OVER
            setupUI()
        }
    }

    // MARK: touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(gameState == GAME_STATE.GAME_OVER)
        {
            level = 1
            let scene = Menu(size:CGSize(width: 1080, height: 1920))
            let skView = self.view as SKView!
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            
            let transition = SKTransition.crossFadeWithDuration(1.0)
            
            skView.presentScene(scene, transition: transition)
        }
        else if(gameState == GAME_STATE.ROUND_OVER)
        {
            level++
            var scene:SKScene!
            if(level > maxLevels)
            {
                scene = Menu(size:CGSize(width: 1080, height: 1920))
            }
            else
            {
                scene = GameScene(size:CGSize(width: 1080, height: 1920))
            }
    
            let skView = self.view as SKView!
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            
            let transition = SKTransition.crossFadeWithDuration(1.0)
            
            skView.presentScene(scene, transition: transition)
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        touchesMoved = true
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(touchesMoved)
        {
            touchesMoved = false
        }
        else
        {
            
        }
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        
    }
    
    func overlapAmount() -> CGFloat
    {
        guard let view = self.view else
        {
            return 0
        }
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        return scaledOverlap
    }
    
    //MARK: Camera
    func getCameraPosition() -> CGPoint
    {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount()/2)
    }
    func setCameraPosition(position:CGPoint)
    {
        cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount()/2)
    }
    
    func moveCamera(movement:CGPoint)
    {
        let bgVelocity = movement * CGFloat(dt)
        cameraNode.position = bgVelocity
    }
    
    //MARK: Collision physics
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Player != 0))
        {
            print(firstBody.categoryBitMask)
            print(secondBody.categoryBitMask)
            playerCollidedElse(firstBody.node as! SKSpriteNode, other: secondBody.node as! SKSpriteNode)
        }
    }
    
}