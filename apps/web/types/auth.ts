export type RoleCode =
  | "super_admin"
  | "admin"
  | "surveyor"
  | "supervisor"
  | "finance"
  | "management";

export type CurrentUser = {
  id: string;
  name: string;
  email: string;
  roles: RoleCode[];
  permissions: string[];
  profile?: {
    surveyor_profile_id?: string | null;
  };
};

export type LoginResult = {
  access_token: string;
  refresh_token: string;
  token_type: "Bearer";
  expires_in: number;
  user: CurrentUser;
};

export type RefreshResult = {
  access_token: string;
  refresh_token: string;
  token_type: "Bearer";
  expires_in: number;
};