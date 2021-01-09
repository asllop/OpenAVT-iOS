//
//  ViewController.m
//  ExamplePlayer-ObjC
//
//  Created by Andreu Santaren on 06/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

#import "ViewController.h"
#import "ExamplePlayer_ObjC-Swift.h"

@import AVKit;

@interface ViewController ()

@property (nonatomic) AVPlayerViewController *playerController;


@end

@implementation ViewController

- (IBAction)clickBunny:(id)sender {
    [self playVideo:@"http://docs.evostream.com/sample_content/assets/hls-bunny-rangerequest/playlist.m3u8"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.playerController.isBeingDismissed) {
        [OAVTInstrumentBridge stopTracking];
    }
}

- (void)playVideo:(NSString *)videoURL {
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:videoURL]];
    self.playerController = [[AVPlayerViewController alloc] init];
    self.playerController.player = player;
    self.playerController.showsPlaybackControls = YES;
    
    [OAVTInstrumentBridge startTrackingWithPlayer:player];
    
    [self presentViewController:self.playerController animated:YES completion:^{
        [self.playerController.player play];
    } ];
}

@end
