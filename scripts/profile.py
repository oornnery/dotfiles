from typing import List, Dict, TYPE_CHECKING, Any

from archinstall.default_profiles.profile import Profile, ProfileType, GreeterType
from archinstall.default_profiles.desktops.kde import KdeProfile
from archinstall.default_profiles.desktops.hyprland import HyprlandProfile


if TYPE_CHECKING:
	from archinstall.lib.installer import Installer
	_: Any


class MyCustomProfile(Profile):
	def __init__(
		self,
	name: str,
		enabled: bool = False,
		packages: List[str] = [],
		services: List[str] = []
	):
		# packages.append(*KdeProfile.packages, *HyprlandProfile.packages)
		super().__init__(
			name,
			ProfileType.CustomType,
			packages=packages,
			services=services,
			support_gfx_driver=True,
			support_greeter=True
		)

		self.custom_enabled = enabled
		self.default_greeter_type = GreeterType.Sddm
		
	def json(self) -> Dict[str, Any]:
		return {
			'name': self.name,
			'packages': self.packages,
			'services': self.services,
			'enabled': self.custom_enabled
		}