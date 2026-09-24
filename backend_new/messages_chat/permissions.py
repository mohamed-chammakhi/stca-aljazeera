from users.models import User


CONTACTS_AUTORISES = {
    User.Role.CHEF_DEGUSTATION: [
        User.Role.COLLECTEUR,
        User.Role.DIRECTION,
        User.Role.CHEF_DEGUSTATION,
    ],
    User.Role.COLLECTEUR: [User.Role.CHEF_DEGUSTATION, User.Role.DIRECTION],
    User.Role.DIRECTION: [User.Role.COLLECTEUR, User.Role.CHEF_DEGUSTATION],
}


def roles_contacts_autorises(user):
    return CONTACTS_AUTORISES.get(getattr(user, 'role', None), [])
