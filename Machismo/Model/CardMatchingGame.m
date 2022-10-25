//
//  CardMatchingGame.m
//  Machismo
//
//  Created by wellzhu on 2022/10/12.
//

#import "CardMatchingGame.h"
#import "PlayingCard.h"

@interface CardMatchingGame()
@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, strong) NSMutableArray *cards; // of Card
@property (nonatomic, readwrite) NSString *text;
@end

@implementation CardMatchingGame

- (NSMutableArray *)cards {
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck {
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                [self.cards addObject:card];
            } else {
                // 若deck里剩余的牌不够初始化，则返回nil
                self = nil;
                break;
            }
        }
        self.mode = 2;
    }
    
    return self;
}

// 使用index获取cards中的牌，可以避免crash
- (Card *)cardAtIndex:(NSUInteger)index {
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;
- (void)chooseCardAtIndex:(NSUInteger)index {
    // 选择index卡牌
    Card *card = [self cardAtIndex:index];
    // 若卡牌未匹配过
    if (!card.isMatched) {
        // 若卡牌已选择，则取消选择，并翻面
        if (card.isChosen) {
            card.chosen = NO;
            self.text = @"";
        } else {
            // 根据游戏模式做不同策略
            self.text = card.contents;
            // 将所有待匹配卡片放入数组
            NSMutableArray *otherCards = [[NSMutableArray alloc] init];
            for (Card *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    [otherCards addObject:otherCard];
                }
            }
            // 3-match需要三张，2-match需要两张
            if (self.mode-1 == [otherCards count]) {
                int matchScore = [card match:otherCards];
                if (matchScore) {
                    self.score += matchScore * MATCH_BONUS;
                    // 如果匹配成功，则将卡牌都设为匹配成功
                    card.matched = YES;
                    for (Card *otherCard in otherCards) {
                        otherCard.matched = YES;
                    }
                    // 修改显示文字
                    self.text = [NSString stringWithFormat:@"Matched %@", card.contents];
                    for (Card *otherCard in otherCards) {
                        self.text = [self.text stringByAppendingString:otherCard.contents];
                    }
                    self.text = [NSString stringWithFormat:@"%@ for %d points.", self.text, matchScore * MATCH_BONUS];
                } else {
                    self.score -= MISMATCH_PENALTY;
                    // 为匹配的话其它卡牌则取消选择，并翻面
                    for (Card *otherCard in otherCards) {
                        otherCard.chosen = NO;
                    }
                    // 修改显示文字
                    self.text = card.contents;
                    for (Card *otherCard in otherCards) {
                        self.text = [self.text stringByAppendingString:otherCard.contents];
                    }
                    self.text = [NSString stringWithFormat:@"%@ don't matched!%d point penalty!", self.text, MISMATCH_PENALTY];
                }
            }
            self.score -= COST_TO_CHOOSE;
            card.chosen = YES;
        }
    }
}
@end
