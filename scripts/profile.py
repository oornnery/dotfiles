from typing import List, Dict, TYPE_CHECKING, Any

from archinstall.default_profiles.profile import Profile, ProfileType, GreeterType
from archinstall.default_profiles.desktops.kde import KdeProfile
from archinstall.default_profiles.desktops.hyprland import HyprlandProfile


if TYPE_CHECKING:
	from archinstall.lib.installer import Installer
	_: Any

__packages__ = []

class MyCustomProfile(Profile):
	def __init__(self):
		# packages.append(*KdeProfile.packages, *HyprlandProfile.packages)
		super().__init__(
			'MyCustomProfile',
			ProfileType.CustomType,
			description=str(_('My custom profile')),	
			support_gfx_driver=True,
			support_greeter=True
		)
		self.custom_enabled = enabled

	@property
	def packages(self) -> List[str]:
		return [
			'nano',
			'vim',
			'openssh',
			'htop',
			'wget',
			'iwd',
			'wireless_tools',
			'wpa_supplicant',
			'smartmontools',
			'xdg-utils'
		]

	@property
	def default_greeter_type(self) -> Optional[GreeterType]:
		combined_greeters: Dict[GreeterType, int] = {}
		for profile in self.current_selection:
			if profile.default_greeter_type:
				combined_greeters.setdefault(profile.default_greeter_type, 0)
				combined_greeters[profile.default_greeter_type] += 1

		if len(combined_greeters) >= 1:
			return list(combined_greeters)[0]

		return None

	def post_install(self, install_session: 'Installer'):
		for profile in self._current_selection:
			profile.post_install(install_session)

	def install(self, install_session: 'Installer'):
		# Install common packages for all desktop environments
		install_session.add_additional_packages(self.packages)

		for profile in self._current_selection:
			info(f'Installing profile {profile.name}...')

			install_session.add_additional_packages(profile.packages)
			install_session.enable_service(profile.services)

			profile.install(install_session)