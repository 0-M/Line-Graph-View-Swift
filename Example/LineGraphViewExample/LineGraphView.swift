//
//  LineGraphView.swift
//  LineGraphViewExample
//
//  Created by Maximilian Markmanrud on 3/18/15.
//  Copyright (c) 2015 mmarkman. All rights reserved.
//


// USAGE:
//      1) Add UIView to storyboard
//      2) In Utilities pane on right, select class LineGraphView
//      3) In Utilities pane on right, turn ON "Show Example Data"
//      4) In Utilities pane on right, adjust cosmetic properties (Optional)
//      5) In Utilities pane on right, turn OFF "Show Example Data"
//      6) Call myGraph.addData(array of Strings for X-axis labels, array of Floats for Y-values) from parent VC
//      7) Call myGraphView.setNeedsDisplay()



//      how to format data:
//      floats:[Float]   = [0.1, 0.5, 0.33, 0.21, 0.5]
//      strings:[String] = ["M", "T",  "W", "Th", "F"]   

//       NOTE THAT THE ORDER OF THESE ARRAYS
//      DECIDES THE ORDER OF DATA ON THE GRAPH


import UIKit

@IBDesignable class LineGraphView: UIView {

    @IBInspectable var showExampleData:Bool = false
    @IBInspectable var graphTitle:String!
    @IBInspectable var lineWidth:CGFloat = 1.5
    @IBInspectable var axesWidth:CGFloat = 1.5
    @IBInspectable var axesColor:UIColor = UIColor.blackColor()
    @IBInspectable var leftPadding:CGFloat = CGFloat(20.0)
    @IBInspectable var rightPadding:CGFloat = CGFloat(20.0)
    @IBInspectable var topPadding:CGFloat = CGFloat(20.0)
    @IBInspectable var bottomPadding:CGFloat = CGFloat(20.0)
    @IBInspectable var showLabels:Bool = true
    @IBInspectable var labelSize:CGFloat = 12
    @IBInspectable var labelColor:UIColor = UIColor.darkGrayColor()
    @IBInspectable var showLabelsX:Bool = true
    @IBInspectable var labelSizeX:CGFloat = 12
    @IBInspectable var labelColorX:UIColor = UIColor.darkGrayColor()
    @IBInspectable var showLabelsY:Bool = true
    @IBInspectable var labelSizeY:CGFloat = 12
    @IBInspectable var labelColorY:UIColor = UIColor.darkGrayColor()
    @IBInspectable var showPoints:Bool = true
    @IBInspectable var pointSize:CGFloat = CGFloat(7.5)
    @IBInspectable var pointColor:UIColor = UIColor.darkGrayColor()
    @IBInspectable var pointsAreButtons:Bool = true
    
    var dataSetsKeys: [[String]] = []
    var dataSetsVals: [[Float]]  = []
    var dataColors: [UIColor]  = []
    var dataActions: [Selector] = []
    var dataTargets: [AnyObject] = []
    
    var maxYval:CGFloat = CGFloat.min
    var minYval:CGFloat = CGFloat.max
    var numPaths = 0
    var pathsDrawn = false
    var labelsDrawnX = false
    var numLabelsX = 7
    
    
    override func drawRect(rect: CGRect) {
        
        if showExampleData == true {
            addData(dataStrings, values: dataFloats, color: UIColor.grayColor())
        }
        
        if graphTitle != nil {
            if topPadding < 25 {
                println("add more top padding or remove title")
            }
        }
        
        /* CRITICAL - where the drawing happens */
        drawPaths()
        drawAxes()
    }
    
    func drawPath(keys: [String], values: [Float], target: AnyObject, action: Selector) {
        
        let height:CGFloat = self.frame.height - (bottomPadding + topPadding)
        let width = self.frame.width - (leftPadding + rightPadding) - 50
        
        var path = UIBezierPath()
        path.lineWidth = self.lineWidth
        
        let num = CGFloat(keys.count)
        
        for var i = 0; i < keys.count; ++i {
            
            var val = CGFloat(values[i])
            var y:CGFloat = (height/CGFloat(2.0)) + topPadding
            var x:CGFloat = ((CGFloat(i) / num) * width) + leftPadding + 25
            
            if CGFloat(maxYval - minYval) != CGFloat(0) {
                y = height - (((val - minYval) / (maxYval - minYval)) * height) + topPadding
            }
            if i == 0 {
                // starting point
                path.moveToPoint(CGPoint( x:x, y:y))
            } else {
                //add a point to the path at the end of the stroke
                path.addLineToPoint(CGPoint(x:x, y:y))
            }
        }
        // DRAW THE LINE, THIS IS ENOUGH
        path.stroke()
        
        
        for var i = 0; i < keys.count; ++i {
            
            let val = CGFloat(values[i])
            let key = keys[i]
            
            
            var x:CGFloat = ((CGFloat(i) / num) * width) + leftPadding + 25
            var y:CGFloat!
            if (maxYval - minYval) == 0 {
                y = height/2 + topPadding
            } else {
                y = height - (((val - minYval) / (maxYval - minYval)) * height) + topPadding
            }
            
            /* LABELS FOR Y-VALUES */
            if showLabels == true && labelOnI(i, total: keys.count, width: width) {
                var labelx = x - 25
                var labely = y - 25
                var labelwidth = CGFloat(50)
                var labelheight = CGFloat(16)
                labely = max(labely, labelheight)
                
                var valueLabel = UILabel(frame: CGRect(x: labelx, y: labely, width: labelwidth, height: labelheight))
                valueLabel.text = "\(val)"
                valueLabel.textAlignment = NSTextAlignment.Center
                valueLabel.font = valueLabel.font.fontWithSize(labelSize)
                valueLabel.textColor = labelColor
                addSubview(valueLabel)
            }
            /* LABELS FOR X-AXIS */
            if showLabelsX == true && labelsDrawnX == false && labelOnI(i, total: keys.count, width: width) {
                
                var labelwidth = CGFloat(50)
                var labelheight = CGFloat(16)
                var labelx = x - 25
                var labely = bounds.height - ((bottomPadding-labelheight)/2) - labelheight
                labely = max(labely, labelheight)
                
                var valueLabel = UILabel(frame: CGRect(x: labelx, y: labely, width: labelwidth, height: labelheight))
                valueLabel.text = key
                valueLabel.textAlignment = NSTextAlignment.Center
                valueLabel.font = valueLabel.font.fontWithSize(labelSize)
                valueLabel.textColor = labelColor
                addSubview(valueLabel)
            }
            /* POINTS */
            if showPoints == true{
                var pointx = x - pointSize/2
                var pointy = y - pointSize/2
                var point = UIBezierPath(ovalInRect: CGRect(x: pointx, y: pointy, width: pointSize, height: pointSize))
                pointColor.setFill()
                point.fill()
            }
            /* POINTBUTTONS */
            if pointsAreButtons == true && action != nil {
                var pointx = x - pointSize/2
                var pointy = y - pointSize/2
                var button = UIButton(frame: CGRect(x: pointx, y: pointy, width: pointSize, height: pointSize))
                button.tag = i
                button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
                self.addSubview(button)
            }
        }
        labelsDrawnX = true
    }
    
    func addData(keys: [String], values: [Float], color: UIColor = UIColor.blackColor(), target: AnyObject = "self", action: Selector = nil) {
        
        if values.count == keys.count {
            if var test = target as? NSString {
                if test == "self" {
                    dataTargets.append(self)
                }
            } else {
                dataTargets.append(target)
            }
            
            dataSetsKeys.append(keys)
            dataSetsVals.append(values)
            dataColors.append(color)
            dataActions.append(action)
            var maxVal = CGFloat.min
            var minVal = CGFloat.max
            for value in values{
                let val = CGFloat(value)
                if val > maxVal{
                    maxVal = val
                }
                if val < minVal{
                    minVal = val
                }
            }
            if (maxVal > maxYval) {
                maxYval = maxVal
            }
            if (minVal < minYval) {
                minYval = minVal
            }
        } else {
            println("Error: Data mismatch for key/values")
        }
    }
    
    func drawPaths(){
        for var i=0; i < dataSetsKeys.count; ++i {
            dataColors[i].setStroke()
            drawPath(dataSetsKeys[i], values: dataSetsVals[i], target: dataTargets[i], action: dataActions[i])
        }
    }
    
    func drawAxes(){
        
        /* draw lines */
        var xAxis = UIBezierPath()
        var yAxis = UIBezierPath()
        let ySpace = bounds.height - bottomPadding
        
        // bottom left
        xAxis.moveToPoint(CGPoint(x:leftPadding , y:ySpace))
        // to bottom right
        xAxis.addLineToPoint(CGPoint(x: bounds.width - rightPadding, y: ySpace))
        
        // top left
        yAxis.moveToPoint(CGPoint(x:leftPadding , y:topPadding))
        // to bottom left
        yAxis.addLineToPoint(CGPoint(x: leftPadding, y: bounds.height - bottomPadding))
        
        axesColor.setStroke()
        
        xAxis.stroke()
        yAxis.stroke()
        
        /* add numerations*/
        
        
    }
    
    func labelOnI(i: Int, total: Int, width:CGFloat) -> Bool {
        var width = self.frame.width
        var labelWidth = CGFloat(50)
        
        
        let numLabels = width / labelWidth
        if numLabels == 0 {
            return true
        }
        
        let interval = total / Int(numLabels)
        if interval == 0 {
            return true
        }
        
        if (i % interval) == 0 {
            return true
        } else {
            return false
        }
    }
    
    func roundTo(x : Float, closest : Int) -> Int {
        return Int(closest) * Int(round(x / Float(closest)))
    }
    
    // garbage test data
    var dataStrings:[String] = ["3/5", "3/6", "3/7", "3/8", "3/9", "3/10", "3/11", "3/5", "3/6", "3/7", "3/8", "3/9", "3/10", "3/11", "3/5", "3/6", "3/7", "3/8", "3/9", "3/10", "3/11", "3/5", "3/6", "3/7", "3/8", "3/9", "3/10", "3/11", "3/5", "3/6", "3/7", "3/8", "3/9", "3/10", "3/11", "3/5", "3/6", "3/7", "3/8", "3/9", "3/10", "3/11"]
    var dataFloats: [Float] = [150, 200, 211, 213, 500, 0, 666, 150, 200, 211, 213, 500, 0, 666, 150, 200, 211, 213, 500, 0, 666, 150, 200, 211, 213, 500, 0, 666, 150, 200, 211, 213, 500, 0, 666, 150, 200, 211, 213, 500, 0, 666]
    // end of bad terrible garbage
    
}
