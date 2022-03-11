//
//  AVFoundationExtensions.swift
//  Vitals
//
//  Created by Eric Ziegler on 3/11/22.
//  Copyright © 2022 Zigabytes. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

func playHaptic() {
    AudioServicesPlaySystemSound(1519)
}
