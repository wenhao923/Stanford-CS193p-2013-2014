//
//  ViewController.m
//  Machismo
//
//  Created by wellzhu on 2022/9/29.
//

#import "ViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "CardMatchingGame.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) CardMatchingGame *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeButton;
@end

@implementation ViewController

- (CardMatchingGame *)game {
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                          usingDeck:[self createDeck]];
    return _game;
}

- (Deck *)createDeck {
    return [[PlayingCardDeck alloc] init];
}

- (IBAction)touchCardButton:(UIButton *)sender {
    // 点击button禁用mode控件
    self.modeButton.enabled = FALSE;
    long chosenButtonIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:chosenButtonIndex];
    [self updateUI];
}
- (IBAction)touchRestartButton:(UIButton *)sender {
    // 点击restart后启用mode控件
    self.modeButton.enabled = TRUE;
    [self.scoreLabel setText:@"Score: 0"];
    BOOL tempMode = self.game.mode;
    self.game = nil;
    self.game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[self createDeck]];
    self.game.mode = tempMode;
    [self updateUI];
}

- (IBAction)selectModeButton:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.game.mode = TRUE;
        NSLog(@"1");
    } else if (sender.selectedSegmentIndex == 1) {
        self.game.mode = FALSE;
        NSLog(@"2");
    }
}


- (void)updateUI {
    // 遍历所有Button
    for (UIButton *cardButton in self.cardButtons) {
        // 从Button获取card（View到Model）
        long cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardButtonIndex];
        // 设置标题
        [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
        // 若Button匹配成功，则禁止点击
        cardButton.isAccessibilityElement = !card.isMatched;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", (int)self.game.score];
    }
}

- (NSString *)titleForCard:(Card *)card {
    return card.isChosen ? card.contents : @"";
}
@end
