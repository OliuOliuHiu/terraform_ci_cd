import { Controller, Get, Header } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  // Thiếu @Header này browser sẽ hiện HTML dưới dạng chữ thô (text/plain).
  @Get()
  @Header('Content-Type', 'text/html; charset=utf-8')
  getProfilePage(): string {
    return this.appService.getProfilePage();
  }

  // Endpoint JSON, tiện kiểm tra nhanh bằng curl mà không phải đọc cả trang HTML.
  @Get('api/profile')
  getProfile() {
    return this.appService.getProfile();
  }
}
