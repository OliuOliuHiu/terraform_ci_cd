import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('trả về trang HTML kèm tên trong profile', () => {
      const html = appController.getProfilePage();

      expect(html).toContain('<!doctype html>');
      expect(html).toContain(appController.getProfile().name);
    });

    it('endpoint JSON trả về profile', () => {
      const profile = appController.getProfile();

      expect(profile.name).toBeTruthy();
      expect(profile.skills.length).toBeGreaterThan(0);
    });
  });
});
