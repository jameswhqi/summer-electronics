# 电子技术小学期工作日志

## 8-28 周一

### 上午

#### 模块调试

- **霍尔** 确认当模块上的电位器调到合适的值时，靠近霍尔元件的磁铁可使输出信号由高电平变为低电平，并确认灵敏度不可调。

- **红外** 发现商家给的电路图有问题，对灵敏度进行了调整，使红外模块可以正常工作。

- **颜色** 能工作，对红蓝敏感，绿色较不敏感（等有颜色的亚克力板到货时再测）。

- **舵机** 能通过输入300Hz的PWM信号控制舵机转角。

### 下午

**电机调试** 确认电机驱动模块正常工作。

**车模调整** 将部分垫圈拆除，使前轮转动更灵活。

**电源管理电路** 将TPS54160和排针焊接到了DIP10转接座上。学习如何使用Altium Designer，并将电源管理电路的原理图完成，各元件封装设定好。

## 8-29 周二

### 上午

**电源管理电路** 在面包板上搭建电源管理电路，发现无法工作，初步调试后未发现问题所在，怀疑TPS54160芯片有问题。在Altium Designer中，完成了PCB布局。

### 下午

**电源管理电路** 又将另两块TPS54160焊至转接座，在调试过程中发现无法工作的原因是有些引脚虚焊，反复尝试后成功焊好了一块芯片，在面包板上调试成功，能输出稳定的5V电压。在Altium Designer中，使元件布局变得更合理，并完成电源管理电路的PCB布线，等待制作PCB。

## 8-30 周三

### 上午

**FPGA** 开始写FPGA代码，开始写核心逻辑模块。

**电源管理电路** 发现电源管理电路的PCB布线宽度不够、焊盘大小不够，重新设定线宽、焊盘、通孔大小。将做好的第一版电源管理电路的PCB发给助教。

### 下午

**FPGA** 完成FPGA核心逻辑模块的编写和测试。

**电源管理电路** 根据助教回复的问题，对PCB进行修改：重画keep out layer，把线距clearance调大。由于7.2V输入端电流很大，为了进一步增加输入端线宽，学习了覆铜处理，并在PCB上应用。

## 8-31 周四

### 上午

**FPGA** 开始写FPGA寻迹与掉头逻辑模块。

**电源管理电路** 用雕刻法制作了第二版PCB，但发现.pcb文件未保存覆铜部分。询问助教发现只能用腐蚀法做有覆铜的板。

### 下午

**FPGA** 完成寻迹与掉头逻辑模块的编写和测试。

**电源管理电路** 更改了PCB上关键元件的位置，使布局更合理。在第二版PCB上练习钻定位孔。

## 9-1 周五

### 上午

**车体组装** 将亚克力板支架安装到小车上，确认其尺寸正确，利用不同长度的铜柱调节某些部分至合适的位置。其中发现前轮转角较大时会触碰红外传感器支架，于是利用备用亚克力延长块使支架位置稍向前偏移。

**电源管理电路** 根据在第二版PCB上试插元器件过程中出现的问题，更改了PCB上关键元件的孔间距等参数，重新布线、覆铜后将第四版PCB发给助教。

### 下午

**电源管理电路** 在第三版PCB上练习钻孔，确定每个孔使用的钻头直径，完成第四版PCB的钻孔、焊接、测试，包括驱动FPGA实验板，确认其满足设计要求。

**颜色传感器** 设计颜色传感器的开关控制电路，并在Altium Designer上画PCB。

## 9-2 周六

**FPGA** 完成舵机驱动、电机驱动、颜色处理模块的编写与调试。

**接口PCB** 完成颜色传感器与霍尔元件接口电路的设计与仿真。

## 9-3 周日

**FPGA** 学习使用FPGA内置ROM的方法，完成数码管和蜂鸣器模块的编写与调试。

**联合调试** 开始进行初步联合调试，发现红外传感器信号存在严重抖动。

**接口电路PCB** 用Altium Designer对接口电路PCB进行布局。

## 9-4 周一

### 上午

**防抖** 用示波器观察红外传感器信号，证实抖动的存在。

**接口PCB** 在面包板上验证接口电路的可行性；在Altium Designer中完成接口电路PCB的布线。

### 下午

**FPGA** 加入红外传感器防抖模块。

**联合调试** 在白板上贴电工胶带进行微型场地模拟，初步调试后发现需要增加刹车功能，并想到了更加科学的掉头算法，决定将车头的中间两个红外传感器移至后轮前方。

**接口PCB** 从助教处得到接口电路PCB并开始打孔。

## 9-5 周二

### 上午

**场地** 完成场地图的绘制。

**接口PCB** 接口电路PCB完成打孔和焊接。

### 下午

**FPGA** 重写掉头算法，增加刹车和颜色传感器LED控制功能。

**联合调试** 完成小车整体结构的搭建，完成第二轮联合调试。

**场地** 去打印店下单打印场地。

**接口PCB** 对接口电路PCB各个引脚进行测试，修改其中短路的部分，最终PCB可正常工作。

## 9-6 周三

### 上午

**场地** 去打印店取走印好的场地图。

**联合调试** 在场地上调试小车。

### 下午

**联合调试** 调整后方红外传感器的位置，继续调试，完成验收。

## 9-7 周四

### 上午

**电源管理电路** 为解决TPS54160接触不良的问题，重新焊接芯片到转接座

**视频** 开始拍摄和剪辑视频。

### 下午

**电源管理电路** 重新焊接芯片到转接座后，发现仍不能稳定工作，仔细检查后发现问题其实在于焊在转接座上的排针与焊在PCB上的排针座之间接触不良，于是将排针座拆除，将排针直接焊在PCB上，电路终于得以稳定工作。

**视频** 完成视频素材拍摄，继续剪辑视频。