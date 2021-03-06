/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import MaterialMotionRuntime

final class RotatablePerformer: NSObject, ComposablePerforming {
  let target: UIView

  private var previousRotation: CGFloat = 0

  required init(target: Any) {
    self.target = target as! UIView
    self.target.isUserInteractionEnabled = true
    super.init()
  }

  func addPlan(_ plan: Plan) {
    guard let plan = plan as? Rotatable else {
      fatalError("RotatablePerformer can only add Rotatable plans.")
    }

    let recognizer = plan.rotationGestureRecognizer
    recognizer.addTarget(self, action: #selector(handle(gesture:)))

    if recognizer.view == nil {
      target.addGestureRecognizer(recognizer)
    }

    if plan.shouldAdjustAnchorPointOnGestureStart {
      recognizer.addTarget(self, action: #selector(modifyAnchorPoint(using:)))
    }
  }

  func handle(gesture: UIGestureRecognizer) {
    guard let gesture = gesture as? UIRotationGestureRecognizer else { return }

    // Apply transform
    if gesture.state == .began {
      previousRotation = 0
    }

    let rotation = gesture.rotation - previousRotation
    target.transform = target.transform.rotated(by: rotation)
    previousRotation = gesture.rotation
  }

  func modifyAnchorPoint(using gesture: UIGestureRecognizer) {
    if gesture.state != .began { return }

    emitter.emitPlan(makeAnchorPointAdjustment(using: gesture, on: target))
  }

  var emitter: PlanEmitting!
  func setPlanEmitter(_ planEmitter: PlanEmitting) {
    emitter = planEmitter
  }
}
