# luci-app-zzz

**luci-app-zzz** is a Front-end interface in openwrt for zzz - the modern 802.1x standard authentication client.

<p align="center">
  <img src="https://github.com/Dichgrem/luci-app-zzz/blob/main/screenshot.png" width="400">
</p>

## How to use

- Step 0: Make sure you have an ``openwrt router``, ``download the ipk`` in Releases in this project, and ``upload and install`` it in the system-package of the Luci background.
- Step 1：Fill in the user name: Student ID@operator. For example, ``212306666@cucc``, China Unicom is cucc, mobile is cmcc, and telecom is ctcc.
- Step 2: Fill in the password. The ``initial password`` is the last six digits of the ID card by default. It can be modified in the official client.
- Step 3: Select your network card; generally speaking, you can use ``ip addr`` to view the network card that has been assigned an IP, such as eth1.
- Step 4: ``Start the service`` and observe whether you can access the Internet, and then enable ``scheduled startup``; because the campus network will be closed from 12:00 to 7:00 the next day.
- Finally，enjoy it!

## How to build

- First clone this repository to the package directory of the openwrt you want to compile:

```
## Add feed
echo "src-git zzz https://github.com/Dichgrem/luci-app-zzz.git" >> feeds.conf.default
## Update and install feed
./scripts/feeds update
./scripts/feeds install luci-app-zzz zzz
```
- Then select ``Network->zzz`` and ``LuCI->Applications->luci-app-zzz`` in make menuconfig and change them to "M" state;

- Finally, run
```
make package/luci-app-zzz/clean V=s
make package/luci-app-zzz/compile V=s
```
and
```
make package/zzz/clean V=s
make package/zzz/compile V=s
```
to start build.

- You can use this command to find the compiled ipk:

```
❯ find bin/ -name "zzz*.ipk"
bin/packages/x86_64/base/zzz_1.0.0-r1_x86_64.ipk
❯ find bin/ -name "luci-app-zzz*.ipk"
bin/packages/x86_64/base/luci-app-zzz_0_all.ipk
```

## Acknowledgements

- [diredocks/zzz](https://github.com/diredocks/zzz)
- [diredocks/nyn](https://github.com/diredocks/nyn)
- [bitdust/njit8021xclient](https://github.com/bitdust/njit8021xclient)
