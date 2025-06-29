import { CanActivate, ExecutionContext, Injectable } from "@nestjs/common";
import { Reflector } from "@nestjs/core";


@Injectable()
export class RolesGuard implements CanActivate{
    constructor(private reflector :Reflector){}

    canActivate(context: ExecutionContext): boolean {
        const requiredRole = this.reflector.get<string>('role',context.getHandler());
        if(!requiredRole) return true;

        const request= context.switchToHttp().getRequest();
        const user =request.user;
        
        console.log('🔐 RolesGuard Debug:');
        console.log('Required role:', requiredRole);
        console.log('User object:', user);
        console.log('User usertype:', user?.usertype);
        console.log('Role check result:', user?.usertype === requiredRole);

        return user?.usertype === requiredRole;
    }
}