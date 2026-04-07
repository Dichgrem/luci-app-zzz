include $(TOPDIR)/rules.mk

PKG_NAME:=zzz
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PKG_MAINTAINER:=Dichgrem <brcefy@gmail.com>
PKG_LICENSE:=MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/diredocks/zzz.git
PKG_SOURCE_VERSION:=556193f42989f2b80c6df6f0e9432cbcdceedce7
PKG_MIRROR_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/zzz
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ZZZ 802.1x Authentication Client
  URL:=https://github.com/diredocks/zzz
  DEPENDS:=+libpcap
endef

define Package/zzz/description
  A 802.1x authentication client for OpenWrt routers.
  Built from source for optimal performance and compatibility.
endef

define Package/zzz/conffiles
/etc/config/zzz
/etc/zzz/config.ini
endef

MESON_ARGS += -Dc_std=gnu11

define Package/zzz/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/zzz

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/zzz $(1)/usr/bin/zzz
	$(INSTALL_BIN) ./files/usr/bin/zzz-device-info $(1)/usr/bin/
	$(INSTALL_CONF) ./files/etc/config/zzz $(1)/etc/config/
	$(INSTALL_CONF) ./files/etc/zzz/config.ini $(1)/etc/zzz/
	$(INSTALL_BIN) ./files/etc/init.d/zzz $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,zzz))
