<p align="right">
  <a href="README.md">English</a> |
  <a href="README.zh-CN.md">简体中文</a>
</p>

# luci-app-zzz

**luci-app-zzz** is a LuCI front-end for **zzz**, an open-source implementation of the **H3C 802.1X campus network client** for OpenWrt.

<p align="center">
  <img src="https://github.com/Dichgrem/luci-app-zzz/blob/main/screenshot.png" width="400">
</p>

## How to use

- **Step 0:** Make sure you have an **OpenWrt router**. Download an `.ipk` or `.apk` file from the **Releases** section of this project, upload it, and install it through the **LuCI package manager**.
  Alternatively, you can integrate this project into your OpenWrt firmware during compilation; see the **How to build** section below.

- **Step 1:** Fill in the **username** in the format `StudentID@operator`.
  For example: `212306666@cucc`.
  China Unicom uses `cucc`, China Mobile uses `cmcc`, and China Telecom uses `ctcc`.

- **Step 2:** Enter the password. By default, the **initial password** is the last six digits of your ID card. It can be changed in the official client.

- **Step 3:** Select your network interface. Usually, you can run `ip addr` to check the interface assigned by your university, for example `eth1`.

- **Step 4:** Start the service and check whether you can access the Internet. Then enable **scheduled startup**, because the campus network is usually unavailable from **00:00 to 07:00**.

- **Finally:** Enjoy!

---

## How to build

First, add this repository to the OpenWrt feeds:

```bash
## Add feed
echo "src-git zzz https://github.com/Dichgrem/luci-app-zzz.git" >> feeds.conf.default

## Update and install feed
./scripts/feeds update
./scripts/feeds install luci-app-zzz zzz
````

Then select:

```text
Network → zzz
LuCI → Applications → luci-app-zzz
```

in `make menuconfig` and set them to **M**.

Finally run:

```bash
make package/luci-app-zzz/clean V=s
make package/luci-app-zzz/compile V=s
```

and

```bash
make package/zzz/clean V=s
make package/zzz/compile V=s
```

to start the build.

You can use the following commands to locate the compiled packages:

```bash
find bin/ -name "zzz*.ipk"
bin/packages/x86_64/base/zzz_1.0.0-r1_x86_64.ipk

find bin/ -name "luci-app-zzz*.ipk"
bin/packages/x86_64/base/luci-app-zzz_0_all.ipk

find bin/ -name "luci-i18n-zzz*.ipk"
bin/packages/x86_64/base/luci-i18n-zzz-zh-cn_26.063.52301~6e658ac_all.ipk
```

Or if you are using **OpenWrt 25.x**:

```bash
find bin/ -name "zzz*.apk"
bin/packages/aarch64_cortex-a53/zzz/zzz-2.0.1-r1.apk

find bin/ -name "luci-app-zzz*.apk"
bin/packages/aarch64_cortex-a53/zzz/luci-app-zzz-2.0.1-r1.apk

find bin/ -name "luci-i18n-zzz*.apk"
bin/packages/aarch64_cortex-a53/zzz/luci-i18n-zzz-zh-cn-26.064.09925~74381fd.apk
```

---

## Add Feeds

To keep this project up to date, you can either upload package files manually, or add the repository feed to receive updates alongside your system packages. To add the feed:

Replace `ARCH` with your device architecture (`x86_64` / `aarch64_cortex-a53` / `aarch64_generic` / `mipsel_24kc` / `i386_pentium4` / `arm_cortex-a9_vfpv3-d16` / `arm_cortex-a7_neon-vfpv4`).

### APK (OpenWrt 25.12+)

```bash
# Trust public key
wget -O /etc/apk/keys/zzz.pem \
    https://Dichgrem.github.io/luci-app-zzz/apk/ARCH/key.pub.pem

# Add repository source
echo "https://Dichgrem.github.io/luci-app-zzz/apk/ARCH/packages.adb" \
    >> /etc/apk/repositories

# Install
apk update && apk add luci-app-zzz
```

### IPK (OpenWrt 24.10 / opkg)

```bash
# Trust public key
wget -O /etc/opkg/keys/47620a6da8acd29e \
  https://Dichgrem.github.io/luci-app-zzz/ipk/aarch64_cortex-a53/key-build.pub

# Add repository source
echo "src/gz zzz https://Dichgrem.github.io/luci-app-zzz/ipk/ARCH" \
    >> /etc/opkg/customfeeds.conf

# Install
opkg update && opkg install luci-app-zzz
```

---

## Acknowledgements

- [https://github.com/diredocks/zzz](https://github.com/diredocks/zzz)
- [https://github.com/diredocks/nyn](https://github.com/diredocks/nyn)
- [https://github.com/bitdust/njit8021xclient](https://github.com/bitdust/njit8021xclient)
