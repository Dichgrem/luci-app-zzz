<p align="right">
  <a href="README.md">English</a> |
  <a href="README.zh-CN.md">简体中文</a>
</p>

# luci-app-zzz

**luci-app-zzz** 是 **zzz** 的 LuCI 前端界面，而 **zzz** 是一个在 OpenWrt 上运行的 **H3C 802.1X 校园网客户端的开源实现**。

<p align="center">
  <img src="https://github.com/Dichgrem/luci-app-zzz/blob/main/screenshot.png" width="400">
</p>

## 使用方法

- **步骤 0：** 确保你拥有一台 **OpenWrt 路由器**。
  从本项目的 **Releases** 页面下载 `.ipk` 或 `.apk` 文件，上传并通过 **LuCI 软件包管理器**安装。
  或者你也可以在编译openwrt的时候将本项目集成到其中；见编译方法。

- **步骤 1：** 填写 **用户名**，格式为 `学号@运营商`。
  例如：`212306666@cucc`。

  运营商代码如下：

  - 中国联通：`cucc`
  - 中国移动：`cmcc`
  - 中国电信：`ctcc`

- **步骤 2：** 输入密码。
  默认情况下，**初始密码**为身份证后 **6 位**，可以在官方客户端中修改。

- **步骤 3：** 选择你的网络接口。
  通常可以运行 `ip addr` 查看学校为你分配的 IP 地址的接口，例如 `eth1`。

- **步骤 4：** 启动服务并检查是否可以访问互联网。
  之后可以启用 **定时启动**，因为校园网通常在 **00:00 到 07:00** 之间关闭。

- **完成：** 享受使用！

---

## 编译方法

首先将本仓库添加到 OpenWrt 的 feeds：

```bash
## 添加 feed
echo "src-git zzz https://github.com/Dichgrem/luci-app-zzz.git" >> feeds.conf.default

## 更新并安装
./scripts/feeds update
./scripts/feeds install luci-app-zzz zzz
````

然后在 `make menuconfig` 中选择：

```text
Network → zzz
LuCI → Applications → luci-app-zzz
```

并将它们设置为 **M**。

最后运行：

```bash
make package/luci-app-zzz/clean V=s
make package/luci-app-zzz/compile V=s
```

以及

```bash
make package/zzz/clean V=s
make package/zzz/compile V=s
```

开始编译。

可以使用以下命令查找编译完成的软件包：

```bash
find bin/ -name "zzz*.ipk"
bin/packages/x86_64/base/zzz_1.0.0-r1_x86_64.ipk

find bin/ -name "luci-app-zzz*.ipk"
bin/packages/x86_64/base/luci-app-zzz_0_all.ipk

find bin/ -name "luci-i18n-zzz*.ipk"
bin/packages/x86_64/base/luci-i18n-zzz-zh-cn_26.063.52301~6e658ac_all.ipk
```

如果你使用的是 **OpenWrt 25.x**：

```bash
find bin/ -name "zzz*.apk"
bin/packages/aarch64_cortex-a53/zzz/zzz-2.0.1-r1.apk

find bin/ -name "luci-app-zzz*.apk"
bin/packages/aarch64_cortex-a53/zzz/luci-app-zzz-2.0.1-r1.apk

find bin/ -name "luci-i18n-zzz*.apk"
bin/packages/aarch64_cortex-a53/zzz/luci-i18n-zzz-zh-cn-26.064.09925~74381fd.apk
```

---

## 添加软件源

对于本项目的更新，可以通过手动上传软件包更新，也可以通过添加软件源在软件包更新的时候一起更新,添加软件源的方法如下：

将 `ARCH` 替换为你的设备架构（例如 `x86_64` / `aarch64_cortex-a53` / `aarch64_generic` / `mipsel_24kc` / `i386_pentium4` / `arm_cortex-a9_vfpv3-d16` / `arm_cortex-a7_neon-vfpv4`）。

### APK（OpenWrt 25.12+）

```bash
# 信任公钥
wget -O /etc/apk/keys/zzz.pem \
    https://Dichgrem.github.io/luci-app-zzz/apk/ARCH/key.pub.pem

# 添加软件源
echo "https://Dichgrem.github.io/luci-app-zzz/apk/ARCH/packages.adb" \
    >> /etc/apk/repositories

# 安装
apk update && apk add luci-app-zzz
```

### IPK（OpenWrt 24.10 / opkg）

```bash
# 信任公钥
wget -O /etc/opkg/keys/47620a6da8acd29e \
  https://Dichgrem.github.io/luci-app-zzz/ipk/aarch64_cortex-a53/key-build.pub

# 添加软件源
echo "src/gz zzz https://Dichgrem.github.io/luci-app-zzz/ipk/ARCH" \
    >> /etc/opkg/customfeeds.conf

# 安装
opkg update && opkg install luci-app-zzz
```

---

## 致谢

- [https://github.com/diredocks/zzz](https://github.com/diredocks/zzz)
- [https://github.com/diredocks/nyn](https://github.com/diredocks/nyn)
- [https://github.com/bitdust/njit8021xclient](https://github.com/bitdust/njit8021xclient)
