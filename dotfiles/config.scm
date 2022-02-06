(use-modules (srfi srfi-1)) ; for 'remove
(use-modules (gnu ) (nongnu packages linux))
(use-modules (gnu packages xfce))
(use-modules (guix transformations))
(use-modules (gnu system)) ; for sudoers
(use-modules (gnu packages emacs-xyz))
(use-modules (gnu packages version-control))
(use-modules (gnu packages package-management))
(use-modules (gnu packages vim))
(use-modules (gnu packages dunst))
(use-modules (gnu packages fonts))
(use-modules (gnu packages code)) ; the silver searcher
(use-modules (gnu services ))
(use-modules (gnu services networking))
(use-modules (gnu services virtualization))
(use-modules (gnu packages emacs))
(use-modules (gnu services docker))
(use-modules (gnu services cups))
(use-modules (gnu services ssh ))
(use-modules (gnu packages ssh))
(use-modules (gnu packages compton))
(use-modules (gnu packages gnome))
(use-modules (gnu packages image-viewers))
(use-modules (gnu packages xorg))
(use-modules (gnu packages wm))
(use-modules (gnu packages python))
(use-modules (gnu packages rsync))
(use-modules (gnu packages freedesktop))
(use-modules (gnu packages file))
(use-modules (gnu packages gtk))
(use-modules (gnu packages gnupg))
(use-modules (gnu packages samba))
(use-modules (gnu packages music))
(use-modules (gnu packages gnome-xyz))
(use-modules (gnu packages cups))
(use-modules (gnu packages pulseaudio))
(use-modules (gnu packages kde-frameworks))
;; (use-modules (gnu packages python-web))
(use-modules (gnu packages xdisorg))
                                        ;    (use-service-modules nix)
(use-service-modules desktop networking ssh xorg)

;; wilschenk's odd thing I need to figure out: this-file
(define this-file
  (local-file (basename (assoc-ref (current-source-location) 'filename))
              "config.scm"))

;; define additional partitions and bind mounts
(define data-drive
  (file-system
   (device (file-system-label "data"))
   (type "ext4")
   (mount-point "/data")))
(define (%projects-bind-mount) "/data/projects")
(define (%backgrounds-bind-mount) "/data/backgrounds")

;; fix up my touchpad for laptops
(define %xorg-libinput-config
  "Section \"InputClass\"
      Identifier \"libinput touchpad gorto\"
      Driver \"libinput\"
      MatchDevicePath \"/dev/input/event*\"
      MatchIsTouchpad \"on\"

      Option \"NaturalScrolling\" \"on\"
      Option \"Tapping\" \"on\"
      Option \"ClickMethod\" \"clickfinger\"
      # Option \"TappingDrag\" \"on\"
      Option \"DisableWhileTyping\" \"on\"
      Option \"MiddleEmulation\" \"on\"
      Option \"ScrollMethod\" \"twofinger\"
   EndSection
   Section \"InputClass\"
      Identifier \"libinput pointer gorto\"
      MatchIsPointer \"on\"
      MatchDevicePath \"/dev/input/event*\"
      Driver \"libinput\"
      Option \"NaturalScrolling\" \"off\"
      Option \"AccelSpeed\" \"0.3\"
    EndSection")
;;
;; Allow members of the "video" group to change the screen brightness.
(define %backlight-udev-rule
  (udev-rule
   "90-backlight.rules"
   (string-append "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                  "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/%k/brightness\""
                  "\n"
                  "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                  "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/%k/brightness\"")))

;; tell emacs-exwm package to use emacs-next package
(define emacs-exwm-transform1
  (options->transformation
   '((with-input . "emacs=emacs-next"))))
(define %my-desktop-services
  (modify-services %desktop-services
                   ;; Configure the substitute server for the Nonguix repo

                   ;; Suspend the machine when the laptop lid is closed
                   (elogind-service-type config =>
                                         (elogind-configuration (inherit config)
                                                                (handle-lid-switch-external-power 'suspend)))

                   ;; Enable backlight control rules for users
                   (udev-service-type config =>
                                      (udev-configuration (inherit config)
                                                          (rules (cons %backlight-udev-rule
                                                                       (udev-configuration-rules config)))))

                   ;; Add OpenVPN support to NetworkManager
                   (network-manager-service-type config =>
                                                 (network-manager-configuration (inherit config)
                                                                                (vpn-plugins (list network-manager-openvpn))))))

;; the heart of the matter
(operating-system
 (kernel linux)
 (locale "en_US.utf8")
 (host-name "camina")
 (timezone "America/Denver")
 (initrd-modules (append (list "vmd")
                         %base-initrd-modules))

 (keyboard-layout (keyboard-layout "us"
                                   #:options '("ctrl:nocaps") ;; setxkbmap -option to reset
                                   ))

 ;; This will be what is used on the target machine
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (timeout 1)
              (targets (list "/boot/efi"))))

 ;; This is needed to create a bootable USB
 ;;(bootloader (bootloader-configuration
 ;;              (bootloader grub-bootloader)
 ;;              (target "/dev/sda")))

 (firmware (append (list iwlwifi-firmware)
                   %base-firmware))

 (sudoers-file
  (plain-file "sudoers"
              (string-append (plain-file-content %sudoers-specification)
                             (format #f "~a ALL = NOPASSWD: ALL~%"
                                     "gregj"
                                     ))))
 (users (cons* (user-account
                (name "gregj")
                (group "users")
                (supplementary-groups '("wheel" "netdev" "audio" "lp" "video" "docker" "kvm" "libvirt"))
                ;; TODO: Default to name?
                (home-directory "/home/gregj"))
               %base-user-accounts))

 (packages
  (append
   (list
    xfce
    ;; (emacs-exwm-transform1
    ;;  (specification->package "emacs-exwm"))
    emacs-exwm
    emacs-vterm
    emacs-guix
    picom
    upower
    xscreensaver
    git
    flatpak
    vim
    font-hack
    feh
    wmctrl
    xrandr
    autorandr
    arandr
    rofi
    emacs-guix
    polybar
    rsync
    xdg-utils
    `(,gtk+ "bin")
    file
    dunst
    libnotify
    python
    ;; python-google-api-client
    pinentry
    pinentry-gtk2
    adwaita-icon-theme
    papirus-icon-theme
    hicolor-icon-theme
    oxygen-icons
    elementary-xfce-icon-theme
    tango-icon-theme
    setxkbmap
    the-silver-searcher
    cifs-utils
    playerctl
    cups
    ;; gtk+:bin
    (specification->package "pavucontrol")
    ;; xdg-desktop-portal
    ;; xdg-desktop-portal-gtk
    (specification->package "nss-certs"))
   %base-packages))


 (services
  (append
   (list
    ;; Copy current config to /etc/config.scm
    (simple-service 'config-file etc-service-type
                    `(("config.scm" ,this-file)))
    ;; (service slim-service-type
    ;;          (slim-configuration
    ;;           (xorg-configuration
    ;;            (xorg-configuration
    ;;             (keyboard-layout keyboard-layout)
    ;;             (extra-config (list %xorg-libinput-config))))))
    (service gnome-desktop-service-type)
    (service openssh-service-type
             (openssh-configuration
              (x11-forwarding? #t)
              (allow-agent-forwarding? #t)))
    ;; Enable the build service for Nix package manager
    ;;        (service nix-service-type)
    (service docker-service-type)
    (service cups-service-type
             (cups-configuration
              (web-interface? #t)
              (extensions
               (list cups-filters hplip-minimal))))
    (service libvirt-service-type
             (libvirt-configuration
              (unix-sock-group "libvirt")
              (listen-tcp? #t)))
              ;; (tls-port "16555")))

    (set-xorg-configuration
     (xorg-configuration
      (keyboard-layout keyboard-layout)
      (extra-config (list %xorg-libinput-config))))
    )
   ;; (modify-services %my-desktop-services (delete gdm-service-type))
   %my-desktop-services
   ;; %desktop-services
   ))
 (swap-devices (list (swap-space (target (file-system-label "swap")))))
 ;; (file-system-label "swap")))
 (file-systems (cons* (file-system
                       (device (file-system-label "guix"))
                       (mount-point "/")
                       (type "ext4"))
                      ;; Not needed for bootable usb but needed for final system
                      (file-system
                       (device (file-system-label "guix-gnu"))
                       (mount-point "/gnu")
                       (type "xfs"))
                      data-drive
                      (file-system
                       (device (%projects-bind-mount))
                       (mount-point "/home/gregj/projects")
                       (type "none")
                       (flags '(bind-mount))
                       (dependencies (list data-drive)))
                      (file-system
                       (device (%backgrounds-bind-mount))
                       (mount-point "/home/gregj/backgrounds")
                       (type "none")
                       (flags '(bind-mount))
                       (dependencies (list data-drive)))
                      (file-system
                       (device "//172.16.17.5/archive")
                       ;; (title 'device)
                       ;; (options "username=gregj,uid=1000,gid=998,credentials=/home/gregj/.config/.smbfile,user")
                       (options "username=gregj,uid=1000,gid=998,domain=domain,user,rw,noauto")
                       (mount-point "/data/archive")
                       (type "cifs")
                       (mount? #f)
                       (create-mount-point? #t))
                      (file-system
                       (device "//172.16.17.5/attach")
                       ;; (title 'device)
                       ;; (options "username=gregj,uid=1000,gid=998,credentials=/home/gregj/.config/.smbfile,user")
                       (options "username=gregj,uid=1000,gid=998,domain=domain,user,rw,mfsymlinks,noauto")
                       (mount-point "/data/attach")
                       (type "cifs")
                       (mount? #f)
                       (create-mount-point? #t))

                      ;; (setuid-programs (cons (file-append cifs-utils "/sbin/mount.cifs")
                      ;;                        %setuid-programs))


                      (file-system
                       (device (file-system-label "EFI"))
                       (type "vfat")
                       (mount-point "/boot/efi"))
                      (file-system
                       (mount-point "/tmp")
                       (device "none")
                       (type "tmpfs")
                       (check? #f))
                      %base-file-systems)))
