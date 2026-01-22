include $(TOPDIR)/rules.mk

PKG_NAME:=zzz
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Dichgrem <brcefy@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/zzz
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ZZZ 802.1x Authentication Client
  URL:=https://github.com/diredocks/zzz
  DEPENDS:=+libpcap
endef

define Package/zzz/description
  A 802.1x authentication client for OpenWrt routers.
  Cross-compiled C version for optimal performance and compatibility.
endef

define Package/zzz/conffiles
/etc/config/zzz
/etc/zzz/config.ini
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/zzz/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/zzz

	# Install precompiled binary based on architecture
	$(if $(CONFIG_TARGET_x86_64),$(INSTALL_BIN) ./files/bin/zzz-x86_64-linux-musl $(1)/usr/bin/zzz)
	$(if $(CONFIG_TARGET_armvirt_64),$(INSTALL_BIN) ./files/bin/zzz-aarch64-linux-musl $(1)/usr/bin/zzz)
	$(if $(CONFIG_TARGET_bcm27xx_bcm2711),$(INSTALL_BIN) ./files/bin/zzz-aarch64-linux-musl $(1)/usr/bin/zzz)
	$(if $(CONFIG_TARGET_ath79_generic),$(INSTALL_BIN) ./files/bin/zzz-mipsel-linux-musleabi $(1)/usr/bin/zzz)
	$(if $(CONFIG_TARGET_ramips_mt7621),$(INSTALL_BIN) ./files/bin/zzz-mipsel-linux-musleabi $(1)/usr/bin/zzz)
	$(if $(CONFIG_TARGET_mediatek_mt7622),$(INSTALL_BIN) ./files/bin/zzz-aarch64-linux-musl $(1)/usr/bin/zzz)
	$(if $(CONFIG_TARGET_rockchip_armv8),$(INSTALL_BIN) ./files/bin/zzz-aarch64-linux-musl $(1)/usr/bin/zzz)
	# Fallback - try to detect architecture
	$(if $(findstring aarch64,$(ARCH)),$(INSTALL_BIN) ./files/bin/zzz-aarch64-linux-musl $(1)/usr/bin/zzz)
	$(if $(findstring mips,$(ARCH)),$(INSTALL_BIN) ./files/bin/zzz-mipsel-linux-musleabi $(1)/usr/bin/zzz)
	$(if $(findstring x86,$(ARCH)),$(INSTALL_BIN) ./files/bin/zzz-x86_64-linux-musl $(1)/usr/bin/zzz)

	$(INSTALL_BIN) ./files/usr/bin/zzz-device-info $(1)/usr/bin/
	$(INSTALL_CONF) ./files/etc/config/zzz $(1)/etc/config/
	$(INSTALL_CONF) ./files/etc/zzz/config.ini $(1)/etc/zzz/
	$(INSTALL_BIN) ./files/etc/init.d/zzz $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,zzz))
