import pgzrun
import time
import cv2
import numpy as np
import copy
from paddlex.cls import transforms
import paddlex
alpha = 1
# 初始化全局变量
WIDTH = 1200
HEIGHT = 600

mario = Actor("mario_big")
mario.bottomleft = 320, 500
vx = 0  # x速度
vy = 0  # y速度
maxv = 6 * alpha  # 最大速度
g = 0.5 * alpha  # 重力加速度
jump = 15 # 跳跃初速度
walking = 0  # 是否在走路
direction = "right"
mario_jump=False
jumptimes=0

mario_die = Actor("mario_die")
mario_die.bottomleft = -1200, 550
vy_die = 0 * alpha  # 死亡图片速度

gd = []  # 所有地面
gifts = []
enemies = []  # 小兵
traps = []  # 陷阱
flags = []
saves = []

life = 5  # 命数
score = 0  # 得分
savepoint = -1
win = False
move_bg = 0
ground_now = 600

top, right, bottom, left = 50, 35, 300, 285
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH,640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT,480)
cap.set(10, 200)

directions = ['left', 'right', 'up', 'down', 'pause']
template = [cv2.imread(f'./data/test/saved_{i}.png', cv2.IMREAD_GRAYSCALE) for i in range(5)]
last_action = 'pause'
action = 'pause'

class enemy(Actor):
    def __init__(self, **kwargs):
        super().__init__(image="enemy1", **kwargs)
        self.leftlimit = 0
        self.rightlimit = 2000
        self.uplimit = 100
        self.downlimit = 500
        self.v = 3 * alpha
        self.use = True
        self.direction = "left"
        self.vy = 0

    def update(self):
        if self.direction == "left":
            if self.left >= self.leftlimit + self.v:
                self.left -= self.v
            else:
                if self.image == "turtle_left":
                    self.image = "turtle_right"
                self.direction = "right"
        elif self.direction == "right":
            if self.right <= self.rightlimit + self.v:
                self.right += self.v
            else:
                if self.image == "turtle_right":
                    self.image = "turtle_left"
                self.direction = "left"
        elif self.direction == "up":
            if self.top >= self.uplimit + self.v:
                self.bottom -= self.v
            else:
                self.direction = "down"
        elif self.direction == "down":
            if self.bottom <= self.downlimit - self.v:
                self.bottom += self.v
            else:
                self.direction = "up"
                
    def turtle_recover(self):
        if self.image=='turtle_hide':
            self.image='turtle_left'
            self.v=3 * alpha


def set_bg():
    for i in range(50, 600, 50):
        ground = Actor("block2")
        ground.bottomleft = 0, i
        gd.append(ground)

    for i in range(0, 1500, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(1700, 2200, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(2400, 3000, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(3100, 3400, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(5000, 5600, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(5800, 6100, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(6200, 6400, 50):  # 设置关卡
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)

    for i in range(6100,6350,50):
        ground = Actor("block2")
        ground.bottomleft = i, 400
        gd.append(ground)
    
    for i in range(450, 800, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 400
        gd.append(ground)

    for i in range(450, 600, 50):
        ground = Actor("block2")
        ground.bottomleft = 500, i
        gd.append(ground)

    for i in range(400, 600, 50):
        ground = Actor("block2")
        ground.bottomleft = 1800, i
        gd.append(ground)
    for i in range(350, 600, 50):
        ground = Actor("block2")
        ground.bottomleft = 2300, i
        gd.append(ground)

    for i in range(3450, 3600, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 500
        gd.append(ground)
    for i in range(3650, 3800, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 400
        gd.append(ground)
    for i in range(3850, 4000, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 500
        gd.append(ground)
    for i in range(3850, 4000, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 200
        gd.append(ground)
    for i in range(4050, 4400, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 400
        gd.append(ground)
    for i in range(4550, 4900, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 200
        gd.append(ground)
    for i in range(5000, 5300, 50):
        ground = Actor("block2")
        ground.bottomleft = i, 400
        gd.append(ground)
    for i in range(6300,7800,50):
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)
    for i in range(7800,8050,50):
        ground = Actor("ground1")
        ground.bottomleft = i, 450
        gd.append(ground)
    for i in range(8200,9500,50):
        ground = Actor("ground1")
        ground.bottomleft = i, 600
        gd.append(ground)


    ground = Actor("block2")
    ground.bottomleft = 2200, 500
    gd.append(ground)
    ground = Actor("block2")
    ground.bottomleft = 2250, 500
    gd.append(ground)
    ground = Actor("block2")
    ground.bottomleft = -1200, 600
    gd.append(ground)


def set_gift(savepoint_x=320):
    # 设置礼物
    gift = Actor("block1")
    gift.bottomleft = 920 - savepoint_x, 400
    gifts.append(gift)

    gift = Actor("block1")
    gift.bottomleft = 1020 - savepoint_x, 400
    gifts.append(gift)

    gift = Actor("block1")
    gift.bottomleft = 4170 - savepoint_x, 200
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 4220 - savepoint_x, 200
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 5320 - savepoint_x, 400
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 5370 - savepoint_x, 400
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 5420 - savepoint_x, 400
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 5470 - savepoint_x, 400
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 5520 - savepoint_x, 400
    gifts.append(gift)
    
    gift = Actor("block1")
    gift.bottomleft = 5570 - savepoint_x, 400
    gifts.append(gift)
    
    for i in range(2200,2500,50):
        for j in range(300,550,50):
            gift = Actor("coin")
            gift.bottomleft = i - savepoint_x, j
            gifts.append(gift)
            
    gift = Actor("coin")
    gift.bottomleft = 4170 - savepoint_x, 250
    gifts.append(gift)
    
    gift = Actor("coin")
    gift.bottomleft = 4220 - savepoint_x, 250
    gifts.append(gift)
    
    gift = Actor("coin")
    gift.bottomleft = 4170 - savepoint_x, 300
    gifts.append(gift)
    
    gift = Actor("coin")
    gift.bottomleft = 4220 - savepoint_x, 300
    gifts.append(gift)
    
    gift = Actor("coin")
    gift.bottomleft = 4170 - savepoint_x, 350
    gifts.append(gift)
    
    gift = Actor("coin")
    gift.bottomleft = 4220 - savepoint_x, 350
    gifts.append(gift)


def set_enemy(savepoint_x=320):
    # 设置小兵
    aenemy = enemy()
    aenemy.bottomleft = 1120 - savepoint_x, 550
    aenemy.leftlimit = 870 - savepoint_x
    aenemy.rightlimit = 1520 - savepoint_x
    enemies.append(aenemy)

    aenemy = enemy()
    aenemy.bottomleft = 2220 - savepoint_x, 550
    aenemy.leftlimit = 2170 - savepoint_x
    aenemy.rightlimit = 2520 - savepoint_x
    enemies.append(aenemy)

    aenemy = enemy()
    aenemy.image = "turtle_left"
    aenemy.bottomleft = 2720 - savepoint_x, 550
    aenemy.leftlimit = 2670 - savepoint_x
    aenemy.rightlimit = 3320 - savepoint_x
    enemies.append(aenemy)

    aenemy = enemy()
    aenemy.v=3
    aenemy.bottomleft = 5400 - savepoint_x, 350
    aenemy.leftlimit = 5300 - savepoint_x
    aenemy.rightlimit = 5600 - savepoint_x
    enemies.append(aenemy)
    
    aenemy = enemy()
    aenemy.image = "turtle_left"
    aenemy.bottomleft = 6200 - savepoint_x, 550
    aenemy.leftlimit = 6100 - savepoint_x
    aenemy.rightlimit = 6250 - savepoint_x
    enemies.append(aenemy)
    
    for i in range(10):
        aenemy = enemy()
        aenemy.image = "turtle_left"
        aenemy.bottomleft = 6650 - savepoint_x + i*300, 550
        aenemy.v=2+0.5*i
        if i//2:
            aenemy.direvtion='left'
        else:
            aenemy.direvtion='right'
        aenemy.leftlimit = 6620 - savepoint_x
        aenemy.rightlimit = 8120 - savepoint_x
        enemies.append(aenemy)


def set_trap(savepoint_x=320):

    aenemy = enemy()
    aenemy.image = "bomb2"
    aenemy.bottomleft = 5400 - savepoint_x, 450
    aenemy.leftlimit = 5300 - savepoint_x
    aenemy.rightlimit = 5800 - savepoint_x
    aenemy.v = 3
    aenemy.vy = 0 * alpha
    aenemy.use = True
    traps.append(aenemy)


def set_save():
    save0 = Actor("save")
    save0.bottomleft = 320, 550
    saves.append(save0)

    save1 = Actor("save")
    save1.bottomleft = 3700, 350
    saves.append(save1)
    
    save3 = Actor("save")
    save3.bottomleft = 6100, 350
    saves.append(save3)
    
    save4 = Actor("save")
    save4.bottomleft = 7900, 400
    saves.append(save4)


def set_flag():
    flag = Actor("flag")
    flag.bottomleft = 9000, 550
    flags.append(flag)


def set_all():  # 设置地图
    set_bg()
    set_gift()
    set_enemy()
    set_trap()
    set_flag()
    set_save()
    sounds.theme.stop()
    sounds.theme.play(-1)


def reset_lives(savepoint_x):  # 重新设置活动对象
    gifts.clear()
    set_gift(savepoint_x)
    enemies.clear()
    set_enemy(savepoint_x)
    traps.clear()
    set_trap(savepoint_x)


def on_ground():  # 判断是否在地面
    global gd, mario, jumptimes
    for i in gd:
        if (
            i.collidepoint(mario.midbottom)
            and i.bottom > mario.bottom > i.top > mario.top
            and last_bottom <= i.top
        ):
            jumptimes=0
            return True
        # if i.colliderect(mario.midbottom) and mario.bottom==i.top+1:
        #    return True
    return False


def top_collide():  # 判断上部碰撞
    global gd, mario
    for i in gd:
        if mario.colliderect(i) and i.top < mario.top <= i.bottom < mario.bottom:
            return True
    return False


def left_collide():  # 判断左边碰撞
    global gd, mario
    for i in gd:
        if (
            mario.colliderect(i)
            and i.left < mario.left <= i.right < mario.right
            and not last_bottom <= i.top + 1
        ):
            mario.left += 7
            return True
    return False


def right_collide():  # 判断右边碰撞
    global gd, mario
    for i in gd:
        if (
            mario.colliderect(i)
            and i.right > mario.right >= i.left > mario.left
            and not last_bottom <= i.top + 1
        ):
            mario.left -= 7
            return True
    return False


def die():  # 死亡
    global vx, vy, vy_die
    mario.image = "mario_die"
    mario_die.bottomleft = mario.left, mario.bottom
    a = gd[0].left
    mario.bottomleft = a - 1200, 550
    vy_die = -50
    vx = 0
    vy = 0
    stop_move()
    walking = 0
    clock.unschedule(walk)
    sounds.theme.stop()
    sounds.die.play()


def death_animation():  # 死亡动画
    global vy_die
    if life > 0:
        vy_die += 5
        mario_die.bottom += vy_die
        if mario_die.bottom >= 700:
            refresh()
            return


def refresh():  # 复活
    global life, vx, vy, vy_die, score, savepoint
    life -= 1
    if life > 0:
        vx = 0
        vy = 0
        vy_die = 0
        distance_back = 320 - saves[savepoint].left
        savepoint_height = saves[savepoint].bottom
        savepoint_x = saves[savepoint].left - gd[0].left
        for i in gd + flags + saves:
            i.left += distance_back
        score = 0
        walking = 0
        reset_lives(savepoint_x)
        mario.image = "mario_big"
        mario.bottomleft = 320, savepoint_height
        mario_die.bottomleft = gd[0].left - 1200, 550
        sounds.theme.play(-1)
    
    else:
        sounds.fail.play()


def set_mario_normal():
    global mario_jump
    mario_jump=False


def move_mario():  # 控制mario运动
    global vx, vy, maxv, g, jump, last_bottom, jumptimes, mario_jump, action
    if mario.image == "mario_die":  # 死亡动画
        death_animation()
    # 左右移动
    else:
        if (keyboard.left or action == 'left') and (keyboard.right or action == 'right'):
            vx = 0
        elif keyboard.left or action == 'left':  # 向左运动
            if left_collide():
                vx = 0
            elif mario.left <= 0:
                vx = 0
            elif vx > -maxv:
                vx -= 1 * alpha
            mario.left += vx
        elif keyboard.right or action == 'right':  # 向右运动
            if right_collide():
                vx = 0
            elif vx < maxv:
                vx += 1 * alpha
            mario.left += vx
        else:  # 停止
            if on_ground():
                vx = 0
        # 上下移动
        if (on_ground() or (mario.left-gd[0].left>10900 and jumptimes<2 and mario_jump==False)) and (keyboard.a or keyboard.up or action == 'up'):  # 只有落地可以跳跃
            vy = -jump
            mario_jump=True
            jumptimes+=1
            last_bottom = mario.bottom
            mario.bottom += vy
            clock.schedule_unique(set_mario_normal,1)
        elif not on_ground():
            if vy < 14.5 * alpha:
                vy += g
            last_bottom = mario.bottom
            mario.bottom += vy
            if mario.top <= 0:
                vy = 0
        else:
            vy = 0
        if top_collide():
            vy = abs(vy)


def check_underground():  # 检查是否低于地面
    global gd, mario, ground_now
    for i in gd:
        if (
            mario.colliderect(i)
            and i.bottom > mario.bottom > i.top > mario.top
            and last_bottom <= i.top
        ):
            ground_now = i.top
            return True
        if mario.colliderect(i) and mario.bottom == i.top + 1:
            ground_now = i.top
            return True
    return False


# 判断是否触发
def nearby():
    global mario
    for i in traps:
        if i.image == "bomb1" and mario.distance_to(i) <= 150 and i.use == False:
            i.v = 3 * alpha
            i.direction = "up"
            i.use = True
        if i.image == "bomb2" and mario.distance_to(i) <= 150 and i.use == False:
            if (
                i.bottomleft[1] == 280
                or i.bottomleft[1] == 380
                or i.bottomleft[1] == 480
            ):
                i.v = 0
                i.direction = "left"
                i.use = True
            else:
                i.v = 2
                i.direction = "left"
                i.use = True
    return True


def judge_trap_used():
    for i in traps:
        pass
        """
        if i.image == 'bomb' and i.bottomleft[0] <= i.leftlimit + 5 or i.image == 'bomb' and i.bottomleft[0] >= i.rightlimit - 5:
            i.v = 0
        """
        # if i.image == 'bomb' and i.bottomleft[0] >= i.rightlimit - 100 or i.image == 'bomb' and i.bottom <= i.uplimit:
        # i.v = 0
        # i.vy = 0
    return False


# 处理移动时的动画
def set_stop():
    if direction == "right":
        mario.image = "mario_big"
    else:
        mario.image = "mario_left"
    clock.unschedule(walk)


def walk():
    if mario.image == "mario_big":
        mario.image = "mario_walk"
    elif mario.image == "mario_walk":
        mario.image = "mario_big"
    elif mario.image == "mario_walkleft":
        mario.image = "mario_left"
    elif mario.image == "mario_left":
        mario.image = "mario_walkleft"


# 获取金币
def get_gift():
    global score,life
    for i in gifts:
        if i.image == "block1":
            if (
                mario.colliderect(i) and i.top < mario.top <= i.bottom < mario.bottom
            ):  # 只有从下面接触才会产生金币
                i.image = "coin"
                i.top -= 50
        elif i.image == "coin":
            if mario.colliderect(i):
                score += 1
                if score>=50 and score%50==0:
                    life+=1
                gifts.remove(i)


def hurt():  # 受到伤害
    global life, score, vy,life
    for i in enemies + traps:
        if i.image == "enemy3" or i.image == "turtle_died":
            i.v = 0
            i.vy += 0.5 * alpha
            i.bottom += i.vy
            if i.bottom >= 700:
                enemies.remove(i)
        elif mario.colliderect(i):
            if mario.bottom <= i.top + 15:
                if i.image == "enemy1":
                    # 敌人死亡
                    i.image = "enemy3"
                    score += 1
                    if score>=50 and score%50==0:
                        life+=1
                elif i.image == "turtle_left" or i.image == "turtle_right":
                    i.image = "turtle_hide"
                    v0 = i.v
                    i.v = 0
                    vy = -15 * alpha
                    mario.bottom-=15
                    clock.schedule_unique(i.turtle_recover, 10)
                elif i.image == "turtle_hide":
                    vy = -15 * alpha
                    i.image = "turtle_died"
                    mario.bottom-=15
                    score += 2
                    if score>=50 and score%50==0:
                        life+=1
                else:
                    die()
            else:
                die()


def fall():  # 失足坠落
    global life
    if mario.bottom >= 700 and life > 0:
        die()


# 控制背景的移动
def move_all():
    global mario, move_bg
    if mario.left > 900 and mario.image != "mario_die":
        move_bg = 1
        clock.schedule(stop_move, 1)
    elif mario.left < 300 and mario.image != "mario_die":
        move_bg = 2
        clock.schedule(stop_move, 1)
    if move_bg == 1:
        mario.left -= 10 * alpha
        for i in gd + gifts + enemies + traps + flags + saves:
            i.left -= 10 * alpha
        for i in enemies + traps:
            i.leftlimit -= 10 * alpha
            i.rightlimit -= 10 * alpha
    elif move_bg == 2:
        mario.left += 10 * alpha
        for i in gd + gifts + enemies + traps + flags + saves:
            i.left += 10 * alpha
        for i in enemies + traps:
            i.leftlimit += 10 * alpha
            i.rightlimit += 10 * alpha


def stop_move():
    global move_bg
    move_bg = 0


def clear_all():
    screen.clear()
    gd.clear()
    gifts.clear()
    enemies.clear()
    traps.clear()
    flags.clear()
    saves.clear()


def game_over():
    clear_all()
    screen.draw.text("GAME OVER!", (400, 300), color="red", fontsize=96)
    screen.draw.text("Press R to RESTART", (950, 10), color="white", fontsize=36)
    if keyboard.r:
        reset_all()


def game_win():
    screen.draw.text("YOU WIN!", (400, 300), color="red", fontsize=96)
    screen.draw.text("Press R to RESTART", (950, 50), color="white", fontsize=36)
    if keyboard.r:
        clear_all()
        reset_all()


def reset_all():
    global life, score, direction, move_bg, ground_now, win, savepoint, mario_jump, jumptimes
    screen.draw.text("GAME RESTART!", (400, 300), color="red", fontsize=96)
    life = 5  # 命数
    score = 0  # 得分
    walking = 0  # 是否在走路
    direction = "right"
    move_bg = 0
    ground_now = 600
    mario_jump=False
    jumptimes=0
    set_all()
    mario.image = "mario_big"
    mario.bottomleft = 320, 550
    mario_die.bottomleft = -1200, 550
    savepoint = -1
    win = False


def draw():
    global life, score, direction, move_bg, ground_now, win, savepoint
    if life > 0:
        screen.clear()
        screen.fill((0, 200, 255))
        screen.draw.text("LIFE:%d" % life, (800, 10), fontsize=48)
        screen.draw.text("SCORE:%d" % score, (1000, 10), fontsize=48)
        for i in gd + gifts + enemies + flags + saves:
            i.draw()
        for i in traps:
            if i.use:
                i.draw()

        mario.draw()
        mario_die.draw()
    else:
        game_over()

    if win:
        game_win()


def update():
    global move_bg, life, ground_now, win, savepoint, last_action, action
    if win:
        return
    left_collide()
    right_collide()
    nearby()
    judge_trap_used()
    for i in enemies + traps:
        i.update()
    move_mario()
    if check_underground():
        mario.bottom = ground_now + 1

    move_all()

    for i in flags:
        if mario.collidepoint(i.midbottom):
            win = True
            print("you win")
    for i in saves:
        if mario.collidepoint(i.midbottom) and i.image == "save":
            i.image = "load"
            savepoint += 1
    get_gift()
    hurt()
    fall()

    ret, frame1 = cap.read()
    frame1 = cv2.bilateralFilter(frame1, 5, 50, 100)  #滤波
    frame1 = cv2.flip(frame1, 1) #翻转
    frame = frame1[top:bottom, right:left].copy()  # 手势位置
    cv2.rectangle(frame1, (left, top),
                  (right, bottom), (0, 255, 0), 2)  # 绘制绿框
    cv2.imshow('original', frame1)

    # 除去背景
    bg = cv2.createBackgroundSubtractorMOG2(0, 50)
    fg = bg.apply(frame)
    kernel = np.ones((3, 3), np.uint8)
    fg = cv2.erode(fg, kernel, iterations=1)
    img = cv2.bitwise_and(frame, frame, mask=fg)


    # 手部检测：二选一
    # 别二选一了，otsu二值化算了……
    ycc = cv2.cvtColor(img,cv2.COLOR_BGR2YCR_CB)
    lower = np.array([0, 140, 83], dtype="uint8")
    upper = np.array([255, 164, 157], dtype="uint8")
    skin = cv2.inRange(ycc, lower, upper)
    skin = cv2.bitwise_not(skin)
    # hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    # lower = np.array([0, 48, 80], dtype="uint8")
    # upper = np.array([20, 255, 255], dtype="uint8")
    # skin = cv2.inRange(hsv, lower, upper)
    # cv2.imshow('hsv Hands', skin)
    # ycc = cv2.cvtColor(img,cv2.COLOR_BGR2YCR_CB)
    # lower = np.array([0, 140, 83], dtype="uint8")
    # upper = np.array([255, 164, 157], dtype="uint8")
    # skin = cv2.inRange(ycc, lower, upper)
    # gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # threshold, skin = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    cv2.resize(skin,(1000,1000))
    cv2.imshow('gray Hands', skin)


    # 奇怪的预测
    max_type = 4
    max_all = 0
    for i in range(5):
        res = cv2.matchTemplate(skin, template[i], cv2.TM_CCOEFF_NORMED)
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
        if max_val > max_all:
            max_all = max_val
            max_type = i
    last_action = action
    action = directions[max_type]
    if action == 'down':
        action = 'pause'
    print(action)
    if last_action != action:
        if last_action == 'left':
            on_key_up(keys.LEFT)
        if last_action == 'right':
            on_key_up(keys.RIGHT)
        if action == 'left':
            on_key_down(keys.LEFT)
        if action == 'right':
            on_key_down(keys.RIGHT)


def on_key_down(key):
    global walking, direction
    if key == keys.LEFT:
        walking = 1
        direction = "left"
        if mario.image != "mario_die":
            mario.image = "mario_left"
            clock.schedule_interval(walk, 0.1)
    if key == keys.RIGHT:
        walking = 1
        direction = "right"
        if mario.image != "mario_die":
            mario.image = "mario_big"
            clock.schedule_interval(walk, 0.1)



def on_key_up(key):
    global walking
    if key == keys.LEFT:
        walking = 0
        if mario.image != "mario_die":
            set_stop()
    if key == keys.RIGHT:
        walking = 0
        if mario.image != "mario_die":
            set_stop()


set_all()

pgzrun.go()

cap.release()
cv2.destroyAllWindows()
