## 一、简介

1. `rTorrent` + `ruTorrent` 一键安装包使用 `Linux Shell` 语言编写，用于在 Linux 操作系统上一键安装 `rTorrent` 和 `ruTorrent`。
2. `rTorrent` + `ruTorrent` 一键安装包基于前文 [《rTorrent + ruTorrent 安装和配置》](http://wangyan.org/blog/rtorrent-and-rutorrent-tutorial.html) 的步骤进行编写，如果要安装`ruTorrent`，那么要求支持PHP的Web环境已经配置好(仅支持Nginx)，否则安装出错。

## 二、下载地址

1. 方法一：通过Git下载（推荐）

    	git clone git://github.com/wangyan/rtrut.git
    	cd rtrut && ./install.sh

2. 方法二：直接下载已打包版本

    	wget http://wangyan.org/download/src/rtrut-latest.tar.gz
    	tar -zxf rtrut-*.tar.gz
    	cd rtrut && ./install.sh

## 三、安装步骤

1. 选择是否需要安装ruTorrent，默认值`y`，如果选择`n`，则跳至最后一步。
2. 输入IP或者域名，默认会自动获取，如果不准确请手动输入。
3. 选择网站根目录，比如：/`var/www`或者`/home/www`
4. 输入Nginx配置文件绝对路径，LANMP一键安装包的默认值是：
    `/usr/local/nginx/conf/vhosts/localhost.conf`
5. 按任意键开始安装，可以按+c退出。

## 四、联系方式

> 如果安装出错，请将安装目录下的 `log.txt` 文件提交给我处理。   
>   
> Email: [WangYan#188.com](WangYan#188.com) （推荐）  
> Gtalk: [myidwy#gmail.com](myidwy#gmail.com)  
> Q Q群：[138082163](http://qun.qq.com/#jointhegroup/gid/138082163)  
> Twitter：[@wang_yan](https://twitter.com/wang_yan)  
> Home Page: [WangYan Blog](http://wangyan.org/blog)  
