//
//  GAGoAgentService.m
//  GoAgentX
//
//  Created by Xu Jiwei on 12-4-24.
//  Copyright (c) 2012年 xujiwei.com. All rights reserved.
//

#import "GAGoAgentService.h"

@implementation GAGoAgentService

- (BOOL)hasConfigured {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"GoAgent:Local:AppId"] length] > 0;
}


- (NSString *)configTemplate {
    NSString *content = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"goagent-config-template" ofType:@""]
                                           encoding:NSUTF8StringEncoding
                                              error:NULL];
    BOOL usePHPFetch = [[NSUserDefaults standardUserDefaults] boolForKey:@"GoAgent:UsePHPFetch"];
    content = [content stringByReplacingOccurrencesOfString:@"{GoAgent:UseGAEFetch}" withString:usePHPFetch ? @"0" : @"1"];
    
    if (usePHPFetch) {
        // PHP 和 GAE 可能会使用同一个端口，如果使用 PHP Fetch，则先将 [listen] 中的端口设置为 0
        NSString *localPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"GoAgent:Local:Port"] ?: @"0";
        content = [content stringByReplacingOccurrencesOfString:@"{GoAgent:Local:PaaSPort}" withString:localPort];
        content = [content stringByReplacingOccurrencesOfString:@"{GoAgent:Local:Port}" withString:@"0"];
    }
    
    return content;
}


- (NSString *)configPath {
    return @"proxy.ini";
}


- (NSString *)serviceName {
    return @"goagent";
}


- (NSString *)serviceTitle {
    return @"goagent";
}


- (int)proxyPort {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"GoAgent:Local:Port"];
}


- (NSString *)proxySetting {
    return [NSString stringWithFormat:@"PROXY 127.0.0.1:%d", [self proxyPort]];
}


- (void)setupCommandRunner {
    [super setupCommandRunner];
    
    commandRunner.commandPath = @"/usr/bin/env";
    commandRunner.arguments = [NSArray arrayWithObjects:@"python", @"proxy.py", nil];
    commandRunner.inputText = nil;
}

@end
